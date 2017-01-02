require 'rails_helper'

RSpec.describe DeviseTokenAuth::SessionsController do
  include Rack::Test::Methods
  include AuthenticationHelper

  def app
    CalorieTracker::Application
  end

  context 'POST /api/v1/auth/sign_in' do
    context 'success requsets' do
      before do
        user_attrs = FactoryGirl.attributes_for(:user)
        password = user_attrs[:password]
        @user = User.create(user_attrs)

        post '/api/v1/auth/sign_in', email: @user.email, password: password
      end

      it 'returns a 200 response' do
        expect(last_response.status).to eq(200)
      end

      it 'returns the User record details' do
        json_body = JSON.parse(last_response.body)
        expect(json_body['data']).not_to be_empty
        expect(json_body['data']['id']).to eq(@user.id)
      end

      it 'returns authorization header values' do
        expect(last_response.headers['Access-Token']).not_to be_empty
        expect(last_response.headers['Client']).not_to be_empty
        expect(last_response.headers['Uid']).to eq(@user.email)
      end
    end

    context 'failure requests' do
      context 'incorrect credentials' do
        before do
          user_attrs = FactoryGirl.attributes_for(:user)
          password = user_attrs[:password]
          user = User.create(user_attrs)

          post '/api/v1/auth/sign_in', email: user.email, password: password[0..-2]
        end

        it 'returns a 401 response' do
          expect(last_response.status).to eq(401)
        end
      end
    end
  end

  context 'GET /api/v1/auth/validate_token' do
    context 'success requsets' do
      before do
        @user = FactoryGirl.create(:user)
        @token = set_auth_headers(@user)

        # Force the request not to be treated as a batched request to validate the access token updating logic.
        get "/api/v1/auth/validate_token", unbatch: true
      end

      it 'returns a 200 response' do
        expect(last_response.status).to eq(200)
      end

      it 'returns the User Record details' do
        json_body = JSON.parse(last_response.body)
        expect(json_body['data']).not_to be_empty
        expect(json_body['data']['id']).to eq(@user.id)
      end

      it 'returns a new access token' do
        @user.reload
        expect(@user.token_is_current?(@token['access-token'], @token['client'])).to be_falsey
        expect(last_response.headers['Access-Token']).not_to be_empty
      end
    end

    context 'failure requests' do
      context 'invalid access token' do
        before do
          @user = FactoryGirl.create(:user)
          @user.create_new_auth_token.each do |key, value|
            value = value[0..-2] if key == 'access-token'
            header(key, value)
          end

          get "/api/v1/auth/validate_token"
        end

        it 'returns a 401 response' do
          expect(last_response.status).to eq(401)
        end
      end
    end
  end

  context 'GET /api/v1/auth/sign_out' do
    context 'success requsets' do
      before do
        @user = FactoryGirl.create(:user)
        @token = set_auth_headers(@user)

        delete "/api/v1/auth/sign_out"
      end

      it 'returns a 200 response' do
        expect(last_response.status).to eq(200)
      end

      it 'expires the token' do
        @user.reload
        expect(@user.tokens[@token['client']]).to be_blank
      end
    end

    context 'failure requests' do
      context 'invalid access token' do
        before do
          @user = FactoryGirl.create(:user)
          @user.create_new_auth_token.each do |key, value|
            value = value[0..-2] if key == 'access-token'
            header(key, value)
          end

          delete "/api/v1/auth/sign_out"
        end

        it 'returns a 404 response' do
          expect(last_response.status).to eq(404)
        end
      end
    end
  end
end
