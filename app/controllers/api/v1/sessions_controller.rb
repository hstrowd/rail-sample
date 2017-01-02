module Api::V1
  class SessionsController < DeviseTokenAuth::SessionsController
    respond_to :json

    # This API will be called from indpendent client applications.
    skip_before_filter :verify_authenticity_token
  end
end
