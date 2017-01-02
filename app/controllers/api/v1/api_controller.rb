module Api::V1
  class ApiController < ApplicationController
    respond_to :json

    # This API will be called from indpendent client applications.
    skip_before_filter :verify_authenticity_token

    # Authenticate user before each request.
    before_action :authenticate_user!

    include DeviseTokenAuth::Concerns::SetUserByToken

    # Add versioning support for the Devise helper methods.
    alias_method :authenticate_user!, :authenticate_api_v1_user!
    alias_method :current_user, :current_api_v1_user
    alias_method :user_signed_in?, :api_v1_user_signed_in?
  end
end
