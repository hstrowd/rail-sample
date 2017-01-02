require 'rails_helper'

RSpec.describe Api::V1::MealsController do
  include Rack::Test::Methods
  include DateTimeHelper
  include AuthenticationHelper

  def app
    CalorieTracker::Application
  end

  before do
    @user = create_and_auth_user
  end

  context 'POST /api/v1/meals' do
    context 'success requsets' do
      before do
        # Clear out the user's meals to start fresh.
        @user.meals.each(&:delete)

        three_days_ago_date = Date.today - 3.days
        two_days_ago_date = Date.today - 2.days
        yesterday_date = Date.today - 1.day
        today_date = Date.today

        breakfast_time = Time.parse('08:15:00')
        brunch_time = Time.parse('11:00:00')
        lunch_time = Time.parse('12:30:00')
        dinner_time = Time.parse('18:45:00')

        three_days_ago_lunch_datetime = DateTime.parse("#{three_days_ago_date.to_s} #{lunch_time.hour}:#{lunch_time.min}:#{lunch_time.sec}")
        @three_days_ago_lunch_meal = FactoryGirl.create(:meal, user: @user, occurred_at: three_days_ago_lunch_datetime)
        two_days_ago_breakfast_datetime = DateTime.parse("#{two_days_ago_date.to_s} #{breakfast_time.hour}:#{breakfast_time.min}:#{breakfast_time.sec}")
        @two_days_ago_breakfast_meal = FactoryGirl.create(:meal, user: @user, occurred_at: two_days_ago_breakfast_datetime)
        two_days_ago_dinner_datetime = DateTime.parse("#{two_days_ago_date.to_s} #{dinner_time.hour}:#{dinner_time.min}:#{dinner_time.sec}")
        @two_days_ago_dinner_meal = FactoryGirl.create(:meal, user: @user, occurred_at: two_days_ago_dinner_datetime)
        yesterday_brunch_datetime = DateTime.parse("#{yesterday_date.to_s} #{brunch_time.hour}:#{brunch_time.min}:#{brunch_time.sec}")
        @yesterday_brunch_meal = FactoryGirl.create(:meal, user: @user, occurred_at: yesterday_brunch_datetime)
        yesterday_dinner_datetime = DateTime.parse("#{yesterday_date.to_s} #{dinner_time.hour}:#{dinner_time.min}:#{dinner_time.sec}")
        @yesterday_dinner_meal = FactoryGirl.create(:meal, user: @user, occurred_at: yesterday_dinner_datetime)
        today_breakfast_datetime = DateTime.parse("#{today_date.to_s} #{breakfast_time.hour}:#{breakfast_time.min}:#{breakfast_time.sec}")
        @today_breakfast_meal = FactoryGirl.create(:meal, user: @user, occurred_at: today_breakfast_datetime)

        @other_user = FactoryGirl.create(:user)
        @other_user.meals.each(&:delete)
        @other_user_meal = FactoryGirl.create(:meal, user: @other_user)
      end

      context 'non-admin users' do
        context 'default params' do
          it 'returns a 20 response' do
            get '/api/v1/meals'
            expect(last_response.status).to eq(200)
          end

          it 'returns all Meal records for the current user' do
            get '/api/v1/meals'

            json_body = JSON.parse(last_response.body)
            expect(json_body['data']).not_to be_empty
            expect(json_body['data'].length).to eq(6)

            expect(json_body['data'][0]['id']).to eq(@today_breakfast_meal.id)
            expect(json_body['data'][1]['id']).to eq(@yesterday_dinner_meal.id)
            expect(json_body['data'][2]['id']).to eq(@yesterday_brunch_meal.id)
            expect(json_body['data'][3]['id']).to eq(@two_days_ago_dinner_meal.id)
            expect(json_body['data'][4]['id']).to eq(@two_days_ago_breakfast_meal.id)
            expect(json_body['data'][5]['id']).to eq(@three_days_ago_lunch_meal.id)
          end

          it 'returns the Meal record details' do
            get '/api/v1/meals'

            json_body = JSON.parse(last_response.body)
            expect(json_body['data']).not_to be_empty
            expect(json_body['data'][0]['id']).to eq(@today_breakfast_meal.id)
            expect(json_body['data'][0]['description']).to eq(@today_breakfast_meal.description)
            expect(json_body['data'][0]['calories']).to eq(@today_breakfast_meal.calories)
            expect(normalize_date_time(json_body['data'][0]['occurred_at'])).to eq(normalize_date_time(@today_breakfast_meal.occurred_at))

            expect(json_body['data'][0]['user']).not_to be_empty
            expect(json_body['data'][0]['user']['id']).to eq(@today_breakfast_meal.user.id)
          end
        end

        context 'with limit' do
          it 'returns at most the specified number of records' do
            get '/api/v1/meals', limit: 3

            json_body = JSON.parse(last_response.body)
            expect(json_body['data'].length).to eq(3)
            expect(json_body['data'][0]['id']).to eq(@today_breakfast_meal.id)
            expect(json_body['data'][1]['id']).to eq(@yesterday_dinner_meal.id)
            expect(json_body['data'][2]['id']).to eq(@yesterday_brunch_meal.id)
          end
        end

        context 'with page' do
          it 'returns the specified page of records' do
            get '/api/v1/meals', limit: 2, page: 2

            json_body = JSON.parse(last_response.body)
            expect(json_body['data'].length).to eq(2)
            expect(json_body['data'][0]['id']).to eq(@yesterday_brunch_meal.id)
            expect(json_body['data'][1]['id']).to eq(@two_days_ago_dinner_meal.id)
          end

          context 'last page' do
            it 'returns a partial page of records' do
              get '/api/v1/meals', limit: 4, page: 2

              json_body = JSON.parse(last_response.body)
              expect(json_body['data'].length).to eq(2)
              expect(json_body['data'][0]['id']).to eq(@two_days_ago_breakfast_meal.id)
              expect(json_body['data'][1]['id']).to eq(@three_days_ago_lunch_meal.id)
            end
          end

          context 'beyond last page' do
            it 'returns a no records' do
              get '/api/v1/meals', limit: 3, page: 3

              json_body = JSON.parse(last_response.body)
              expect(json_body['data']).to be_empty
            end
          end
        end

        context 'with start date' do
          it 'returns only meals that occured since the specified date, inclusively' do
            get '/api/v1/meals', start_date: (Time.now - 1.day).beginning_of_day

            json_body = JSON.parse(last_response.body)
            expect(json_body['data'].length).to eq(3)
            expect(json_body['data'][0]['id']).to eq(@today_breakfast_meal.id)
            expect(json_body['data'][1]['id']).to eq(@yesterday_dinner_meal.id)
            expect(json_body['data'][2]['id']).to eq(@yesterday_brunch_meal.id)
          end
        end

        context ' with end date' do
          it 'returns only meals that occured up until the specified date, inclusively' do
            get '/api/v1/meals', end_date: (Time.now - 2.day).end_of_day

            json_body = JSON.parse(last_response.body)
            expect(json_body['data'].length).to eq(3)
            expect(json_body['data'][0]['id']).to eq(@two_days_ago_dinner_meal.id)
            expect(json_body['data'][1]['id']).to eq(@two_days_ago_breakfast_meal.id)
            expect(json_body['data'][2]['id']).to eq(@three_days_ago_lunch_meal.id)
          end
        end

        context 'with both start and end dates' do
          it 'returns only meals that occured between the specified dates, inclusively' do
            get '/api/v1/meals', start_date: (Time.now - 2.day).beginning_of_day, end_date: (Time.now - 1.day).end_of_day

            json_body = JSON.parse(last_response.body)
            expect(json_body['data'].length).to eq(4)
            expect(json_body['data'][0]['id']).to eq(@yesterday_dinner_meal.id)
            expect(json_body['data'][1]['id']).to eq(@yesterday_brunch_meal.id)
            expect(json_body['data'][2]['id']).to eq(@two_days_ago_dinner_meal.id)
            expect(json_body['data'][3]['id']).to eq(@two_days_ago_breakfast_meal.id)
          end
        end

        context 'with only start hour' do
          it 'returns only meals that occured since the specified hour of the day, inclusively' do
            get '/api/v1/meals', start_hour: 11

            json_body = JSON.parse(last_response.body)
            expect(json_body['data'].length).to eq(4)
            expect(json_body['data'][0]['id']).to eq(@yesterday_dinner_meal.id)
            expect(json_body['data'][1]['id']).to eq(@yesterday_brunch_meal.id)
            expect(json_body['data'][2]['id']).to eq(@two_days_ago_dinner_meal.id)
            expect(json_body['data'][3]['id']).to eq(@three_days_ago_lunch_meal.id)
          end
        end

        context 'with only end hour' do
          it 'returns only meals that occured up until the specified hour of the day, inclusively' do
            get '/api/v1/meals', end_hour: 12

            json_body = JSON.parse(last_response.body)
            expect(json_body['data'].length).to eq(4)
            expect(json_body['data'][0]['id']).to eq(@today_breakfast_meal.id)
            expect(json_body['data'][1]['id']).to eq(@yesterday_brunch_meal.id)
            expect(json_body['data'][2]['id']).to eq(@two_days_ago_breakfast_meal.id)
            expect(json_body['data'][3]['id']).to eq(@three_days_ago_lunch_meal.id)
          end
        end

        context 'with start and end hour' do
          context 'with a start hour less than the end hour' do
            it 'returns only meals that occured between the specified hours of the day, inclusively' do
              get '/api/v1/meals', start_hour: 10, end_hour: 14

              json_body = JSON.parse(last_response.body)
              expect(json_body['data'].length).to eq(2)
              expect(json_body['data'][0]['id']).to eq(@yesterday_brunch_meal.id)
              expect(json_body['data'][1]['id']).to eq(@three_days_ago_lunch_meal.id)
            end
          end
          context 'with a start hour greater than the end hour' do
            it 'returns only meals that occured after the end hour and before the start hour, inclusively' do
              get '/api/v1/meals', start_hour: 22, end_hour: 8

              json_body = JSON.parse(last_response.body)
              expect(json_body['data'].length).to eq(2)
              expect(json_body['data'][0]['id']).to eq(@today_breakfast_meal.id)
              expect(json_body['data'][1]['id']).to eq(@two_days_ago_breakfast_meal.id)
            end
          end
        end

        context 'with user ID' do
          it 'ignores the specified user ID' do
            get '/api/v1/meals', user_id: @other_user.id

            json_body = JSON.parse(last_response.body)
            expect(json_body['data'].length).to eq(6)
            expect(json_body['data'][0]['id']).to eq(@today_breakfast_meal.id)
          end
        end
      end

      context 'admin users' do
        it 'allows other users\' meals to be retrieved' do
          @user.update_attribute(:role, User::ADMIN_ROLE)

          get '/api/v1/meals', user_id: @other_user_meal.user.id

            json_body = JSON.parse(last_response.body)
            expect(json_body['data'].length).to eq(1)
            expect(json_body['data'][0]['id']).to eq(@other_user_meal.id)
        end
      end
    end

    context 'failure requests' do
      context 'invalid parameter inputs' do
        it 'returns a 422 if the limit is not an integer' do
          get '/api/v1/meals', limit: 'foo'

          expect(last_response.status).to eq(422)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/invalid limit/i)
        end

        it 'returns a 422 if the page is not an integer' do
          get '/api/v1/meals', page: 'foo'

          expect(last_response.status).to eq(422)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/invalid page/i)
        end

        it 'returns a 422 if the start date is not an date' do
          get '/api/v1/meals', start_date: 'foo'

          expect(last_response.status).to eq(422)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/invalid start date/i)
        end

        it 'returns a 422 if the end date is not an date' do
          get '/api/v1/meals', end_date: 'foo'

          expect(last_response.status).to eq(422)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/invalid end date/i)
        end

        it 'returns a 422 if the start hour is not an integer' do
          get '/api/v1/meals', start_hour: 'foo'

          expect(last_response.status).to eq(422)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/invalid start hour/i)
        end

        it 'returns a 422 if the end hour is not an integer' do
          get '/api/v1/meals', end_hour: 'foo'

          expect(last_response.status).to eq(422)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('invalid_request')
          expect(json_body['error']).to match(/invalid end hour/i)
        end
      end

      it 'return a 404 response when the user requested by an admin user is not found' do
        @user.update_attribute(:role, User::ADMIN_ROLE)
        get '/api/v1/meals', user_id: 987

        expect(last_response.status).to eq(404)
        json_body = JSON.parse(last_response.body)
        expect(json_body['code']).to eq('not_found')
        expect(json_body['error']).to match(/user.*not found/i)
      end
    end
  end

  context 'POST /api/v1/meals' do
    context 'success requsets' do
      context 'non-admin users' do
        before do
          @new_meal_attrs = FactoryGirl.attributes_for(:meal, user: @user)
        end

        it 'creates a meal User record' do
          expect {
            post '/api/v1/meals', @new_meal_attrs
          }.to change{Meal.count}.by(1)
        end

        it 'returns a 201 response' do
          post '/api/v1/meals', @new_meal_attrs

          expect(last_response.status).to eq(201)
        end

        it 'returns the Meal record details' do
          post '/api/v1/meals', @new_meal_attrs

          new_meal = Meal.last
          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data']['id']).to eq(new_meal.id)
          expect(json_body['data']['description']).to eq(@new_meal_attrs[:description])
          expect(json_body['data']['calories']).to eq(@new_meal_attrs[:calories])
          expect(normalize_date_time(json_body['data']['occurred_at'])).to eq(normalize_date_time(@new_meal_attrs[:occurred_at]))

          expect(json_body['data']['user']).not_to be_empty
          expect(json_body['data']['user']['id']).to eq(@user.id)
        end
      end

      context 'admin users' do
        before do
          @user.update_attribute(:role, User::ADMIN_ROLE)
          @other_user = FactoryGirl.create(:user)
          @new_meal_attrs = FactoryGirl.attributes_for(:meal)
          @new_meal_attrs[:user_id] = @other_user.id
        end

        it 'permits the creation of Meal records for other users' do
          expect {
            post '/api/v1/meals', @new_meal_attrs
          }.to change{Meal.count}.by(1)

          expect(last_response.status).to eq(201)
          new_meal = Meal.last
          expect(new_meal.user).to eq(@other_user)

          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data']['user']).not_to be_empty
          expect(json_body['data']['user']['id']).to eq(@other_user.id)
        end
      end
    end

    context 'failure requests' do
      before do
        @new_meal_attrs = FactoryGirl.attributes_for(:meal)
      end

      context 'missing attribute' do
        %w(description calories occurred_at).each do |attribute|
          context "missing #{attribute}" do
            before do
              @new_meal_attrs.delete(attribute.to_sym)
            end

            it 'does NOT create a new Meal record' do
              expect {
                post '/api/v1/meals', @new_meal_attrs
              }.not_to change{Meal.count}
            end

            it 'returns a 422 status code' do
              post '/api/v1/meals', @new_meal_attrs

              expect(last_response.status).to eq(422)
            end

            it 'returns an error code and message' do
              post '/api/v1/meals', @new_meal_attrs

              json_body = JSON.parse(last_response.body)
              expect(json_body['code']).to eq('invalid_request')
              expect(json_body['error']).to match(/#{attribute.humanize}.*blank/i)
            end
          end
        end
      end

      it 'return a 404 response when the user requested by an admin user is not found' do
        @user.update_attribute(:role, User::ADMIN_ROLE)
        @new_meal_attrs[:user_id] = 987

        post '/api/v1/meals', @new_meal_attrs

        expect(last_response.status).to eq(404)
        json_body = JSON.parse(last_response.body)
        expect(json_body['code']).to eq('not_found')
        expect(json_body['error']).to match(/user.*not found/i)
      end
    end
  end

  context 'GET /api/v1/meals/:id' do
    context 'success requsets' do
      context 'non-admin users' do
        before do
          @meal = FactoryGirl.create(:meal, user: @user)

          get "/api/v1/meals/#{@meal.id}"
        end

        it 'returns a 200 response status' do
          expect(last_response.status).to eq(200)
        end

        it 'returns the Meal record details' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data']['id']).to eq(@meal.id)
          expect(json_body['data']['description']).to eq(@meal.description)
          expect(json_body['data']['calories']).to eq(@meal.calories)
          expect(normalize_date_time(json_body['data']['occurred_at'])).to eq(normalize_date_time(@meal.occurred_at))

          expect(json_body['data']['user']).not_to be_empty
          expect(json_body['data']['user']['id']).to eq(@meal.user.id)
        end
      end

      context 'admin users' do
        before do
          @user.update_attribute(:role, User::ADMIN_ROLE)
          @other_user = FactoryGirl.create(:user)
          @other_user_meal = FactoryGirl.create(:meal, user: @other_user)

          get "/api/v1/meals/#{@other_user_meal.id}"
        end

        it 'returns a 200 response status' do
          expect(last_response.status).to eq(200)
        end

        it 'returns the other user\'s Meal record details' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data']['id']).to eq(@other_user_meal.id)
          expect(json_body['data']['user']).not_to be_empty
          expect(json_body['data']['user']['id']).to eq(@other_user.id)
        end
      end
    end

    context 'failure requsets' do
      context 'not found' do
        before do
          get '/api/v1/meals/987'
        end

        it 'returns a 404 response status' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no meal found/i)
        end
      end

      context 'not assigned to the current basic user' do
        before do
          meal = FactoryGirl.create(:meal)

          get "/api/v1/meals/#{meal.id}"
        end

        it 'returns a 404 response status' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no meal found/i)
        end
      end
    end
  end

  context 'PUT /api/v1/meals/:id' do
    context 'success requsets' do
      context 'non-admin users' do
        before do
          @meal = FactoryGirl.create(:meal, user: @user)
          @meal_attr_updates = FactoryGirl.attributes_for(:meal)

          put "/api/v1/meals/#{@meal.id}", @meal_attr_updates
        end

        it 'returns a 200 response' do
          expect(last_response.status).to eq(200)
        end

        it 'returns the Meal record details' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['data']).not_to be_empty
          expect(json_body['data']['id']).to eq(@meal.id)
          expect(json_body['data']['description']).to eq(@meal_attr_updates[:description])
          expect(json_body['data']['calories']).to eq(@meal_attr_updates[:calories])
          expect(normalize_date_time(json_body['data']['occurred_at'])).to eq(normalize_date_time(@meal_attr_updates[:occurred_at]))

          expect(json_body['data']['user']).not_to be_empty
          expect(json_body['data']['user']['id']).to eq(@meal.user.id)
        end
      end

      context 'admin users' do
        before do
          @user.update_attribute(:role, User::ADMIN_ROLE)
          @other_user = FactoryGirl.create(:user)
          @other_user_meal = FactoryGirl.create(:meal, user: @other_user)
          @meal_attr_updates = FactoryGirl.attributes_for(:meal)
        end

        context 'updating other user\'s meals' do
          before do
            put "/api/v1/meals/#{@other_user_meal.id}", @meal_attr_updates
          end

          it 'returns a 200 response' do
            expect(last_response.status).to eq(200)
          end

          it 'returns the Meal record details' do
            json_body = JSON.parse(last_response.body)
            expect(json_body['data']).not_to be_empty
            expect(json_body['data']['id']).to eq(@other_user_meal.id)
            expect(json_body['data']['description']).to eq(@meal_attr_updates[:description])
            expect(json_body['data']['calories']).to eq(@meal_attr_updates[:calories])
            expect(normalize_date_time(json_body['data']['occurred_at'])).to eq(normalize_date_time(@meal_attr_updates[:occurred_at]))

            expect(json_body['data']['user']).not_to be_empty
            expect(json_body['data']['user']['id']).to eq(@other_user.id)
          end
        end

        context 'updating the user assigned to other user\`s meals' do
          before do
            @other_user_2 = FactoryGirl.create(:user)

            put "/api/v1/meals/#{@other_user_meal.id}", user_id: @other_user_2.id
          end

          it 'changes the User record assigned to the meaal' do
            @other_user_meal.reload
            expect(@other_user_meal.user).to eq(@other_user_2)
          end

          it 'returns a 200 response' do
            expect(last_response.status).to eq(200)
          end

          it 'returns the Meal record details' do
            json_body = JSON.parse(last_response.body)
            expect(json_body['data']).not_to be_empty
            expect(json_body['data']['id']).to eq(@other_user_meal.id)
            expect(json_body['data']['user']).not_to be_empty
            expect(json_body['data']['user']['id']).to eq(@other_user_2.id)
          end
        end
      end
    end

    context 'failure requests' do
      context 'not found' do
        before do
          meal_attr_updates = FactoryGirl.attributes_for(:meal)
          put '/api/v1/meals/987', meal_attr_updates
        end

        it 'returns a 404 response status' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no meal found/i)
        end
      end

      context 'not assigned to the current basic user' do
        before do
          meal = FactoryGirl.create(:meal)
          meal_attr_updates = FactoryGirl.attributes_for(:meal)

          get "/api/v1/meals/#{meal.id}", meal_attr_updates
        end

        it 'returns a 404 response status' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no meal found/i)
        end
      end

      context 'blank attribute' do
        before do
          @meal = FactoryGirl.create(:meal, user: @user)
          @meal_attr_updates = FactoryGirl.attributes_for(:meal)
        end

        %w(description calories occurred_at).each do |attribute|
          context "blank #{attribute} value" do
            before do
              @meal_attr_updates[attribute.to_sym] = ''
            end

            it 'does NOT create a new Meal record' do
              expect {
                put "/api/v1/meals/#{@meal.id}", @meal_attr_updates
              }.not_to change{Meal.count}
            end

            it 'returns a 422 status code' do
              put "/api/v1/meals/#{@meal.id}", @meal_attr_updates

              expect(last_response.status).to eq(422)
            end

            it 'returns an error code and message' do
              put "/api/v1/meals/#{@meal.id}", @meal_attr_updates

              json_body = JSON.parse(last_response.body)
              expect(json_body['code']).to eq('invalid_request')
              expect(json_body['error']).to match(/#{attribute.humanize}.*blank/i)
            end
          end
        end
      end

      context 'description too long' do
        it 'leaves the record unchanged' do
          @meal = FactoryGirl.create(:meal, user: @user)
          orig_description = @meal.description

          put "/api/v1/meals/#{@meal.id}", description: Faker::Lorem.characters(2001)

          expect(last_response.status).to eq(422)
          @meal.reload
          expect(@meal.description).to eq(orig_description)
        end
      end

      context 'invalid occurred at date' do
        it 'leaves the record unchanged' do
          @meal = FactoryGirl.create(:meal, user: @user)
          orig_occurred_at = @meal.occurred_at

          put "/api/v1/meals/#{@meal.id}", occurred_at: 'invalid_date'

          expect(last_response.status).to eq(422)
          @meal.reload
          expect(@meal.occurred_at).to eq(orig_occurred_at)
        end
      end

      context 'calories too small' do
        it 'leaves the record unchanged' do
          @meal = FactoryGirl.create(:meal, user: @user)
          orig_calories = @meal.calories

          put "/api/v1/meals/#{@meal.id}", calories: 0

          expect(last_response.status).to eq(422)
          @meal.reload
          expect(@meal.calories).to eq(orig_calories)
        end
      end

      context 'calories too large' do
        it 'leaves the record unchanged' do
          @meal = FactoryGirl.create(:meal, user: @user)
          orig_calories = @meal.calories

          put "/api/v1/meals/#{@meal.id}", calories: 10000

          expect(last_response.status).to eq(422)
          @meal.reload
          expect(@meal.calories).to eq(orig_calories)
        end
      end

      context 'user requested by an admin user is not found' do
        it 'return a 404 response' do
          @user.update_attribute(:role, User::ADMIN_ROLE)
          @other_user = FactoryGirl.create(:user)
          @other_user_meal = FactoryGirl.create(:meal, user: @other_user)

          put "/api/v1/meals/#{@other_user_meal.id}", user_id: 987

          expect(last_response.status).to eq(404)
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/user.*not found/i)
        end
      end
    end
  end

  context 'DELETE /api/v1/meals/:id' do
    context 'success requsets' do
      context 'non-admin users' do
        before do
          @meal = FactoryGirl.create(:meal, user: @user)
        end

        it 'removes a Meal record' do
          expect {
            delete "/api/v1/meals/#{@meal.id}"
          }.to change{ Meal.count }.by(-1)

          expect(Meal.find_by(id: @meal.id)).to be_nil
        end

        it 'returns a 204 response' do
          delete "/api/v1/meals/#{@meal.id}"

          expect(last_response.status).to eq(204)
        end
      end

      context 'admin users' do
        before do
          @user.update_attribute(:role, User::ADMIN_ROLE)
          other_user = FactoryGirl.create(:user)
          @other_user_meal = FactoryGirl.create(:meal, user: other_user)
        end

        it 'removes a Meal record' do
          expect {
            delete "/api/v1/meals/#{@other_user_meal.id}"
          }.to change{ Meal.count }.by(-1)

          expect(Meal.find_by(id: @other_user_meal.id)).to be_nil
        end

        it 'returns a 204 response' do
          delete "/api/v1/meals/#{@other_user_meal.id}"

          expect(last_response.status).to eq(204)
        end
      end
    end

    context 'failure requests' do
      context 'not found' do
        before do
          delete '/api/v1/meals/987'
        end

        it 'returns a 404 response status' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no meal found/i)
        end
      end

      context 'not assigned to the current basic user' do
        before do
          meal = FactoryGirl.create(:meal)

          delete "/api/v1/meals/#{meal.id}"
        end

        it 'returns a 404 response status' do
          expect(last_response.status).to eq(404)
        end

        it 'returns an error code and message' do
          json_body = JSON.parse(last_response.body)
          expect(json_body['code']).to eq('not_found')
          expect(json_body['error']).to match(/no meal found/i)
        end
      end
    end
  end
end
