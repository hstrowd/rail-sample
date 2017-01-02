module AuthenticationHelper
  def create_and_auth_user(role = User::BASIC_ROLE)
    user = FactoryGirl.create(:user, role: role)
    set_auth_headers(user)
    return user
  end

  def set_auth_headers(user)
    token = user.create_new_auth_token
    token.each { |k,v| header(k, v) }

    return token
  end
end
