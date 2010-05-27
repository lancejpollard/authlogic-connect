# all these methods must return true or false
module AuthlogicConnect::Oauth::State
  
  # 1. to call
  # checks that we just passed parameters to it,
  # and that the parameters say 'authentication_method' == 'oauth'
  def oauth_request?
    !auth_params.nil? && oauth_provider?
  end
  
  # 2. from call
  # checks that the correct session variables are there
  def oauth_response?
    !oauth_response.nil? && !auth_session.nil? && auth_session[:auth_request_class] == self.class.name && auth_session[:auth_method] == "oauth"
  end
  alias_method :oauth_complete?, :oauth_response?
  
  # 3. either to or from call
  def using_oauth?
    oauth_request? || oauth_response?
  end
  
  def new_oauth_request?
    oauth_response.blank?
  end
  
  def oauth_provider?
    !oauth_provider.nil? && !oauth_provider.empty?
  end
  
  # main method we call on validation
  def authenticating_with_oauth?
    correct_request_class? && using_oauth?
  end
  
  def allow_oauth_redirect?
    authenticating_with_oauth? && !oauth_complete?
  end
  
  # both checks if it can redirect, and does the redirect.
  # is there a more concise way to do this?
  def redirecting_to_oauth_server?
    if allow_oauth_redirect?
      redirect_to_oauth
      return true
    end
    return false
  end
  
  def validate_password_with_oauth?
    !using_oauth? && require_password?
  end
  
end
