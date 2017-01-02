module Api::V1
  class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
    respond_to :json

    # This API will be called from indpendent client applications.
    skip_before_filter :verify_authenticity_token
  end
end
