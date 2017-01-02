module Api::V1
  class MealsController < ApiController
    before_action :lookup_meal, except: [ :index, :create ]
    before_action :validate_user_param, only: [ :index, :create, :update ]

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

        if params[:start_date].present? &&
           !(start_date = params[:start_date].to_time)
          raise 'Invalid Start Date Value. Must be a valid timestamp.'
        end
        if params[:end_date].present? &&
           !(end_date = params[:end_date].to_time)
          raise 'Invalid End Date Value. Must be a valid timestamp.'
        end

        start_hour = params[:start_hour]&.to_i
        if start_hour.present? && (start_hour.to_s != params[:start_hour] || start_hour < 0 || start_hour > 23)
          raise 'Invalid Start Hour Value. Must be an integer between 0 and 23, inclusive.'
        end

        end_hour = params[:end_hour]&.to_i
        if end_hour.present? && (end_hour.to_s != params[:end_hour] || end_hour < 0 || end_hour > 23)
          raise 'Invalid End Hour Value. Must be an integer between 0 and 23, inclusive.'
        end

        user_id = params[:user_id] || current_user.id
      rescue StandardError => e
        render json: { code: 'invalid_request', error: "Invalid request parameters: #{e.message}"}, status: 422
        return
      end

      meals = Meal.where(user_id: user_id)

      if start_date.present?
        meals = meals.where("occurred_at >= ?", start_date)
      end
      if end_date.present?
        meals = meals.where("occurred_at <= ?", end_date)
      end

      if start_hour.present? && end_hour.present?
        if end_hour < start_hour
          # The range spans midnight, so we need to union these conditions instead of intersecting.
          meals = meals.where("DATE_PART('HOUR', occurred_at) >= ? OR DATE_PART('HOUR', occurred_at) <= ?", start_hour, end_hour)
        else
          meals = meals.where("DATE_PART('HOUR', occurred_at) >= ? AND DATE_PART('HOUR', occurred_at) <= ?", start_hour, end_hour)
        end
      else
        if start_hour.present?
          meals = meals.where("DATE_PART('HOUR', occurred_at) >= ?", start_hour)
        end
        if end_hour.present?
          meals = meals.where("DATE_PART('HOUR', occurred_at) <= ?", end_hour)
        end
      end

      meals = meals.order(occurred_at: :desc)
              .limit(page_size)
              .offset((page - 1) * page_size)

      render json: { data: meals }
    end

    def create
      meal_attrs = { 'user_id' => current_user.id }.merge(permitted_params)
      meal = Meal.new(meal_attrs)
      unless meal.save
        render json: { code: 'invalid_request', error: "Invalid meal: #{meal.errors.full_messages.join('; ')}" }, status: 422
        return
      end

      render json: { data: meal }, status: 201
    end

    def show
      render json: { data: @meal }
    end

    def update
      unless @meal.update_attributes(permitted_params)
        render json: { code: 'invalid_request', error: "Invalid meal: #{@meal.errors.full_messages.join('; ')}" }, status: 422
        return
      end

      render json: { data: @meal }
    end

    def destroy
      unless @meal.destroy
        render json: { code: 'invalid_request', error: "Unable to delete meal: #{@meal.errors.full_messages.join('; ')}" }, status: 422
        return
      end

      render json: nil, status: 204
      return
    end

    private

    def lookup_meal
      @meal = Meal.find_by(id: params[:id])
      if @meal.blank?
        render json: { code: 'not_found', error: "No meal found with id #{params[:id]}." }, status: 404
        return false
      end

      if !current_user.admin? && @meal.user != current_user
        render json: { code: 'not_found', error: "No meal found with id #{params[:id]}." }, status: 404
        return false
      end
    end

    def validate_user_param
      # Ignore the user ID param for non-admins.
      unless current_user.admin? && params[:user_id].present?
        params.delete(:user_id)
        return
      end

      user_id = params[:user_id].to_i
      user = User.find_by(id: user_id)

      if user.nil?
        render json: { code: 'not_found', error: "User #{user_id} not found." }, status: 404
        return false
      end
    end

    def permitted_params
      params.permit(:description, :calories, :occurred_at, :user_id)
    end
  end
end
