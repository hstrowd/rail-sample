require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  include Rack::Test::Methods
  include DateTimeHelper
  include AuthenticationHelper

  def app
    CalorieTracker::Application
  end

  context 'GET /api/v1/users' do
    context 'success requsets' do
      before do
        @user_1 = create_and_auth_user(User::USER_MANAGER_ROLE)
        @user_1.update_attributes(created_at: Time.now)

        @user_2 = FactoryGirl.create(:user, created_at: 1.hour.ago)
        @user_3 = FactoryGirl.create(:user, created_at: 12.hours.ago)
        @user_4 = FactoryGirl.create(:user, created_at: 1.day.ago)
        @user_5 = FactoryGirl.create(:user, created_at: 3.days.ago)
      end

      context 'default params' do
        it 'returns a 20 response' do
          get '/api/v1/users'
          expect(last_response.status).to eq(200)
        end

        it 'returns all current User records' do
          get '/api/v1/users'

          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data'].length).to eq(5)

          expect(json_body['data'][0]['id']).to eq(@user_1.id)
          expect(json_body['data'][1]['id']).to eq(@user_2.id)
          expect(json_body['data'][2]['id']).to eq(@user_3.id)
          expect(json_body['data'][3]['id']).to eq(@user_4.id)
          expect(json_body['data'][4]['id']).to eq(@user_5.id)
        end

        it 'returns the User record details' do
          get '/api/v1/users'

          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data'][0]['id']).to eq(@user_1.id)
          expect(json_body['data'][0]['name']).to eq(@user_1.name)
          expect(json_body['data'][0]['email']).to eq(@user_1.email)
          expect(json_body['data'][0]['daily_calorie_target']).to eq(@user_1.daily_calorie_target)
          expect(normalize_date_time(json_body['data'][0]['created_at'])).to eq(normalize_date_time(@user_1.created_at))
        end
      end

      context 'with limit' do
        it 'returns at most the specified number of records' do
          get '/api/v1/users', limit: 3

          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data'].length).to eq(3)
        end
      end

      context 'with page' do
        it 'returns the specified page of records' do
          get '/api/v1/users', limit: 2, page: 2

          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data'].length).to eq(2)
          expect(json_body['data'][0]['id']).to eq(@user_3.id)
          expect(json_body['data'][1]['id']).to eq(@user_4.id)
        end

        it 'returns a partial page of records for the last page' do
          get '/api/v1/users', limit: 2, page: 3

          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data'].length).to eq(1)
          expect(json_body['data'][0]['id']).to eq(@user_5.id)
        end

        it 'returns a no records beyond the last page' do
          get '/api/v1/users', limit: 2, page: 4

          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).to be_empty
        end
      end
    end

    context 'failure requests' do
      context 'unauthorized' do
        context 'no user signed in' do
          it 'returns a 401 status code' do
            get '/api/v1/users'

            expect(last_response.status).to eq(401)
          end
        end

        context 'basic user signed in' do
          before do
            user = create_and_auth_user(User::BASIC_ROLE)
          end

          it 'returns a 401 status code' do
            get '/api/v1/users'

            expect(last_response.status).to eq(401)

            json_body = JSON.parse(last_response.body)
            expect(json_body['code']).to eq('unauthorized')
          end
        end
      end

      context 'invalid parameter inputs' do
        before do
          user = create_and_auth_user(User::ADMIN_ROLE)
        end

        context 'invalid limit' do
          it 'returns a 422 if the limit is too small' do
            get '/api/v1/users', limit: 0

            expect(last_response.status).to eq(422)

            json_body = JSON.parse(last_response.body)
            expect(json_body['code']).to eq('invalid_request')
            expect(json_body['error']).to match(/invalid limit/i)
          end

          it 'returns a 422 if the limit is too large' do
            get '/api/v1/users', limit: 1001

            expect(last_response.status).to eq(422)

            json_body = JSON.parse(last_response.body)
            expect(json_body['code']).to eq('invalid_request')
            expect(json_body['error']).to match(/invalid limit/i)
          end
        end

        context 'invalid page' do
          it 'returns a 422 if the page is too small' do
            get '/api/v1/users', page: 0

            expect(last_response.status).to eq(422)

            json_body = JSON.parse(last_response.body)
            expect(json_body['code']).to eq('invalid_request')
            expect(json_body['error']).to match(/invalid page/i)
          end
        end
      end
    end
  end

  context 'POST /api/v1/users' do
    context 'success requsets' do
      before do
        @new_user_attrs = FactoryGirl.attributes_for(:user)
      end

      it 'creates a new User record' do
        expect {
          post '/api/v1/users', @new_user_attrs
        }.to change{User.count}.by(1)
      end

      it 'returns a 201 response' do
        post '/api/v1/users', @new_user_attrs

        expect(last_response.status).to eq(201)
      end

      it 'returns the User record details' do
        post '/api/v1/users', @new_user_attrs

        new_user = User.last
        json_body = JSON.parse(last_response.body)
        expect(json_body['data']).not_to be_empty
        expect(json_body['data']['id']).to eq(new_user.id)
        expect(json_body['data']['name']).to eq(@new_user_attrs[:name])
        expect(json_body['data']['email']).to eq(@new_user_attrs[:email])
        expect(json_body['data']['daily_calorie_target']).to eq(@new_user_attrs[:daily_calorie_target])
        expect(json_body['data']['created_at']).not_to be_blank
        expect(new_user.valid_password?(@new_user_attrs[:password])).to be_truthy
      end

      it 'forces all new users created by an unauthenticated user to have the basic role' do
        @new_user_attrs[:role] = User::USER_MANAGER_ROLE

        post '/api/v1/users', @new_user_attrs

        expect(last_response.status).to eq(201)
        new_user = User.last
        expect(new_user.role).to eq(User::BASIC_ROLE)
      end

      context 'by basic user' do
        before do
          @current_user = create_and_auth_user(User::BASIC_ROLE)
        end

        it 'forces all new users created by a basic user to have the basic role' do
          @new_user_attrs[:role] = User::USER_MANAGER_ROLE

          post '/api/v1/users', @new_user_attrs

          expect(last_response.status).to eq(201)
          new_user = User.last
          expect(new_user.role).to eq(User::BASIC_ROLE)
        end
      end

      context 'by user manager' do
        before do
          @current_user = create_and_auth_user(User::USER_MANAGER_ROLE)
        end

        it 'allows new user manager records to be created' do
          @new_user_attrs[:role] = User::USER_MANAGER_ROLE

          post '/api/v1/users', @new_user_attrs

          expect(last_response.status).to eq(201)
          new_user = User.last
          expect(new_user.role).to eq(User::USER_MANAGER_ROLE)
        end

        it 'caps the new user\'s role at the user manager level' do
          @new_user_attrs[:role] = User::ADMIN_ROLE

          post '/api/v1/users', @new_user_attrs

          expect(last_response.status).to eq(201)
          new_user = User.last
          expect(new_user.role).to eq(User::USER_MANAGER_ROLE)
        end
      end

      context 'by admin' do
        before do
          @current_user = create_and_auth_user(User::ADMIN_ROLE)
        end

        it 'allows new user manager records to be created' do
          @new_user_attrs[:role] = User::USER_MANAGER_ROLE

          post '/api/v1/users', @new_user_attrs

          expect(last_response.status).to eq(201)
          new_user = User.last
          expect(new_user.role).to eq(User::USER_MANAGER_ROLE)
        end

        it 'allows new admin records to be created' do
          @new_user_attrs[:role] = User::ADMIN_ROLE

          post '/api/v1/users', @new_user_attrs

          expect(last_response.status).to eq(201)
          new_user = User.last
          expect(new_user.role).to eq(User::ADMIN_ROLE)
        end
      end
    end

    context 'failure requests' do
      context 'duplicate email' do
        before do
          existing_user = FactoryGirl.create(:user)
          @new_user_attrs = FactoryGirl.attributes_for(:user, email: existing_user.email)
        end

        it 'does NOT create a new User record' do
          expect {
            post '/api/v1/users', @new_user_attrs
          }.not_to change{User.count}
        end

        it 'returns a 422 status code' do
          post '/api/v1/users', @new_user_attrs

          expect(last_response.status).to eq(422)
        end

        it 'returns an error code and message' do
          post '/api/v1/users', @new_user_attrs

          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/email.*in use/i)
        end
      end

      context 'missing parameter' do
        before do
          @new_user_attrs = FactoryGirl.attributes_for(:user)
        end

        %w(name email password).each do |attribute|
          context "missing #{attribute}" do
            before do
              @new_user_attrs.delete(attribute.to_sym)
            end

            it 'does NOT create a new User record' do
              expect {
                post '/api/v1/users', @new_user_attrs
              }.not_to change{User.count}
            end

            it 'returns a 422 status code' do
              post '/api/v1/users', @new_user_attrs

              expect(last_response.status).to eq(422)
            end

            it 'returns an error code and message' do
              post '/api/v1/users', @new_user_attrs

              json_body = JSON.parse(last_response.body)
              expect(json_body['code']).to eq('invalid_request')
              expect(json_body['error']).to match(/#{attribute.humanize}.*blank/i)
            end
          end
        end
      end

      context 'invalid parameter' do
        before do
          @new_user_attrs = FactoryGirl.attributes_for(:user)
        end

        it 'return a 422 response if the calorie target too small' do
          @new_user_attrs[:daily_calorie_target] = 0

          post '/api/v1/users', @new_user_attrs

          expect(last_response.status).to eq(422)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/daily calorie target must be greater than/i)
        end

        it 'return a 422 response if the calorie target too large' do
          @new_user_attrs[:daily_calorie_target] = 10000

          post '/api/v1/users', @new_user_attrs

          expect(last_response.status).to eq(422)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/daily calorie target must be less than/i)
        end

        it 'returns a 422 response if the requested role is not recognized' do
          current_user = create_and_auth_user(User::ADMIN_ROLE)
          @new_user_attrs[:role] = 'foo'

          post '/api/v1/users', @new_user_attrs

          expect(last_response.status).to eq(422)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/invalid role/i)
        end
      end
    end
  end

  context 'GET /api/v1/users' do
    context 'success requsets' do
      before do
        @user = FactoryGirl.create(:user)
        @token = set_auth_headers(@user)

        # Force the request not to be treated as a batched request to validate the access token updating logic.
        get "/api/v1/users/#{@user.id}", unbatch: true
      end

      it 'returns a 200 response' do
        expect(last_response.status).to eq(200)
      end

      it 'returns the User record details' do
        json_body = JSON.parse(last_response.body)
        expect(json_body['data']).not_to be_empty
        expect(json_body['data']['id']).to eq(@user.id)
        expect(json_body['data']['name']).to eq(@user.name)
        expect(json_body['data']['email']).to eq(@user.email)
        expect(json_body['data']['daily_calorie_target']).to eq(@user.daily_calorie_target)
        expect(json_body['data']['meal_count']).to eq(@user.meals.length)
        expect(json_body['data']['calorie_total']).to eq(@user.meals.collect(&:calories).sum)
        expect(normalize_date_time(json_body['data']['created_at'])).to eq(normalize_date_time(@user.created_at))
      end

      it 'returns a new access token' do
        @user.reload
        expect(@user.token_is_current?(@token['access-token'], @token['client'])).to be_falsey
        expect(last_response.headers['access-token']).not_to be_empty
      end

      context 'by user managers' do
        it 'allws them to retrieve any user' do
          current_user = create_and_auth_user(User::USER_MANAGER_ROLE)

          get "/api/v1/users/#{@user.id}", unbatch: true

          expect(last_response.status).to eq(200)
          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data']['id']).not_to eq(current_user.id)
        end
      end

      context 'by admins' do
        it 'allws them to retrieve any user' do
          current_user = create_and_auth_user(User::ADMIN_ROLE)

          get "/api/v1/users/#{@user.id}", unbatch: true

          expect(last_response.status).to eq(200)
          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data']['id']).not_to eq(current_user.id)
        end
      end
    end

    context 'failure requests' do
      context 'basic user accessing another user\'s record' do
        before do
          create_and_auth_user

          other_user = FactoryGirl.create(:user)
          get "/api/v1/users/#{other_user.id}"
        end

        it 'returns a 404 response' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no user found/i)
        end
      end

      context 'unknown user' do
        before do
          create_and_auth_user

          get "/api/v1/users/#{987}"
        end

        it 'returns a 404 response' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no user found/i)
        end
      end
    end
  end

  context 'PUT /api/v1/users/:user_id' do
    context 'success requsets' do
      context 'for user manager roles' do
        before do
          current_user = create_and_auth_user(User::USER_MANAGER_ROLE)
          @user_to_update = FactoryGirl.create(:user)
          @user_attr_updates = FactoryGirl.attributes_for(:user)

          put "/api/v1/users/#{@user_to_update.id}", @user_attr_updates
        end

        it 'returns a 200 response' do
          expect(last_response.status).to eq(200)
        end

        it 'returns the User record details' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data']['id']).to eq(@user_to_update.id)
          expect(json_body['data']['name']).to eq(@user_attr_updates[:name])
          expect(json_body['data']['email']).to eq(@user_attr_updates[:email])
          expect(json_body['data']['daily_calorie_target']).to eq(@user_attr_updates[:daily_calorie_target])
          expect(normalize_date_time(json_body['data']['created_at'])).to eq(normalize_date_time(@user_to_update.created_at))
        end
      end

      context 'for basic roles' do
        before do
          @current_user = create_and_auth_user(User::BASIC_ROLE)
          @user_attr_updates = FactoryGirl.attributes_for(:user)

          put "/api/v1/users/#{@current_user.id}", @user_attr_updates
        end

        it 'it permits the user to update their own account' do
          expect(last_response.status).to eq(200)

          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data']['id']).to eq(@current_user.id)
        end
      end
    end

    context 'failure requests' do
      context 'not found' do
        before do
          current_user = create_and_auth_user(User::USER_MANAGER_ROLE)
          user_attr_updates = FactoryGirl.attributes_for(:user)

          put '/api/v1/users/987', user_attr_updates
        end

        it 'returns a 404 response' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no user found/i)
        end
      end

      context 'unauthorized user' do
        it 'returns a 404 for basic users updating another user' do
          current_user = create_and_auth_user(User::BASIC_ROLE)
          @user_to_update = FactoryGirl.create(:user)
          @user_attr_updates = FactoryGirl.attributes_for(:user)

          put "/api/v1/users/#{@user_to_update.id}", @user_attr_updates

          expect(last_response.status).to eq(404)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no user found/i)
        end
      end

      context 'blank attributes' do
        %w(name email daily_calorie_target role).each do |attribute|
          context "blank #{attribute}" do
            before do
              current_user = create_and_auth_user(User::USER_MANAGER_ROLE)
              @user_to_update = FactoryGirl.create(:user)

              put "/api/v1/users/#{@user_to_update.id}", attribute.to_sym => ''
            end

            it 'returns a 422 status code' do
              expect(last_response.status).to eq(422)
            end

            it 'returns an error code and message' do
              json_body = JSON.parse(last_response.body)
              expect(json_body['code']).to eq('invalid_request')
              expect(json_body['error']).to match(/#{attribute.humanize}.*blank/i)
            end
          end
        end
      end

      context 'invalid role' do
        before do
          current_user = create_and_auth_user(User::USER_MANAGER_ROLE)
          @user_to_update = FactoryGirl.create(:user)

          put "/api/v1/users/#{@user_to_update.id}", role: 'foo'
        end

        it 'returns a 422 status code' do
          expect(last_response.status).to eq(422)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/invalid role/i)
        end
      end
    end
  end

  context 'DELETE /api/v1/users/:user_id' do
    context 'success requsets' do
      context 'for user manager roles' do
        before do
          current_user = create_and_auth_user(User::USER_MANAGER_ROLE)
          @user_to_delete = FactoryGirl.create(:user)

          delete "/api/v1/users/#{@user_to_delete.id}"
        end

        it 'returns a 204 response' do
          expect(last_response.status).to eq(204)
        end
      end

      context 'for basic roles' do
        before do
          @current_user = create_and_auth_user(User::BASIC_ROLE)

          delete "/api/v1/users/#{@current_user.id}"
        end

        it 'it permits the user to delete their own account' do
          expect(last_response.status).to eq(204)
        end
      end
    end

    context 'failure requsets' do
      context 'not found' do
        before do
          current_user = create_and_auth_user(User::USER_MANAGER_ROLE)

          delete '/api/v1/users/987'
        end

        it 'returns a 404 response' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no user found/i)
        end
      end

      context 'unauthorized user' do
        before do
          current_user = create_and_auth_user(User::BASIC_ROLE)
          @user_to_delete = FactoryGirl.create(:user)

          delete "/api/v1/users/#{@user_to_delete.id}"
        end

        it 'returns a 404 response' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no user found/i)
        end
      end
    end
  end
end
