module Api::V1
  class UsersController < ApiController
    skip_before_filter :authenticate_user!, only: [ :create ]
    before_filter :lookup_user, only: [ :show, :update, :destroy ]
    before_filter :verify_user_access, only: [ :index, :show, :update, :destroy ]

    def index
      begin
        page_size = params[:limit]&.to_i || 50
        if page_size.present? && (page_size < 1 || page_size > 1000)
          raise 'Invalid Limit Value. Must be an integer between 1 and 1000, inclusive.'
        end

        page = params[:page]&.to_i || 1
        if page.present? && page < 1
          raise 'Invalid Page Value. Must be greater than or equal to 1.'
        end
      rescue StandardError => e
        render json: { code: 'invalid_request', error: "Invalid request parameters: #{e.message}"}, status: 422
        return
      end

      users = User.all
      users = users.order(created_at: :desc)
              .limit(page_size)
              .offset((page - 1) * page_size)

      render json: { data: users }
    end

    def create
      user_attrs = permitted_params
      unless user_attrs[:role] = sanitize_requested_role(user_attrs[:role])
        render json: { code: 'invalid_request', error: "Invalid role: #{user_attrs[:role]}" }, status: 422
        return
      end

      user = User.new(user_attrs)
      if user.save
        # email auth has been bypassed, authenticate user
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        user.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }

        user.save!

        if current_user.nil?
          @resource = user
          update_auth_header
        end

        render json: { data: user }, status: 201
      else
        render json: { code: 'invalid_request', error: "Invalid user: #{user.errors.full_messages.join('; ')}" }, status: 422
        return
      end
    end

    def show
      render json: { data: @user }
    end

    def update
      update_attrs = permitted_params
      if update_attrs[:role].present?
        unless update_attrs[:role] = sanitize_requested_role(update_attrs[:role])
          render json: { code: 'invalid_request', error: "Invalid role: #{update_attrs[:role]}" }, status: 422
          return
        end
      end

      unless @user.update_attributes(update_attrs)
        render json: { code: 'invalid_request', error: "Invalid user: #{@user.errors.full_messages.join('; ')}" }, status: 422
        return
      end

      render json: { data: @user }
    end

    def destroy
      sign_out(@user)

      unless @user.destroy
        render json: { code: 'invalid_request', error: "Unable to delete user: #{@user.errors.full_messages.join('; ')}" }, status: 422
        return
      end

      # Attempting to update the authentication header for a deleted resource will fail.
      if @resource == @user
        @resource = nil
      end

      render json: nil, status: 204
      return
    end

    private

    def lookup_user
      @user = User.find_by(id: params[:id])
      if @user.blank?
        render json: { code: 'not_found', error: "No user found with ID: #{params[:id]}" }, status: 404
        return false
      end
    end

    def verify_user_access
      # Return a 401 for uauthenticated request or index requests made by basic users.
      if current_user.nil? || (current_user.basic? && @user.nil?)
        render json: { code: 'unauthorized', error: "Not authorized to perform this action." }, status: 401
        return false
      end

      # Return a 404 for basic user's trying to access other user's account because thy shouldn't even know these records exist.
      if current_user.basic? && @user != current_user
        render json: { code: 'not_found', error: "No user found with ID: #{params[:id]}" }, status: 404
        return false
      end
    end

    def permitted_params
      params.permit(:email, :password, :name, :daily_calorie_target, :role)
    end

    def sanitize_requested_role(requested_role)
      if current_user.nil? || current_user.basic? || requested_role.blank?
        return User::BASIC_ROLE
      end

      unless User::ROLES.include?(requested_role)
        return nil
      end

      capped_role_val = [ User::ROLES[requested_role], User::ROLES[current_user.role] ].min
      return User::ROLES.key(capped_role_val)
    end
  end
end
