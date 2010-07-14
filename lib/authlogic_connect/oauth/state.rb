# all these methods must return true or false
module AuthlogicConnect::Oauth::State
  
  # 1. to call
  # checks that we just passed parameters to it,
  # and that the parameters say 'authentication_method' == 'oauth'
  def oauth_request?
    auth_params? && oauth_provider?
  end
  
  # 2. from call
  # checks that the correct session variables are there
  def oauth_response?
    !oauth_response.nil? && auth_session? && auth_session[:auth_request_class] == self.class.name && auth_session[:auth_method] == "oauth"
  end
  
  def oauth_complete?
    oauth_response? || stored_oauth_token_and_secret?
  end
  
  # 3. either to or from call
  def using_oauth?
    oauth_request? || oauth_response? || stored_oauth_token_and_secret?
  end
  
  def new_oauth_request?
    return false if stored_oauth_token_and_secret?
    return oauth_response.blank?
  end
  
  def oauth_provider?
    !oauth_provider.blank?
  end
  
  # main method we call on validation
  def authenticating_with_oauth?
    correct_request_class? && using_oauth?
  end
  
  def allow_oauth_redirect?
    authenticating_with_oauth? && !oauth_complete?
  end
  
  def start_oauth?
    authenticating_with_oauth? && !oauth_complete?
  end
  
  def complete_oauth?
    using_oauth? && !new_oauth_request?
  end
  
  def validate_password_with_oauth?
    !using_oauth? && require_password?
  end
  
  def stored_oauth_token_and_secret?
    !is_auth_session? && auth_params? && auth_params.has_key?(:_key) && auth_params.has_key?(:_token) && auth_params.has_key?(:_secret)
  end
  
end
