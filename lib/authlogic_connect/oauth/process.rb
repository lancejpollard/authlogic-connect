module AuthlogicConnect::Oauth::Process

  include AuthlogicConnect::Oauth::Variables

  # Step 2: after save is called, it runs this method for validation
  def validate_by_oauth
    validate_email_field = false
    unless new_oauth_request? # shouldn't be validating if it's redirecting...
      restore_attributes
      complete_oauth_transaction
    end
  end
  
  # Step 3: if new_oauth_request?, redirect to oauth provider
  def redirect_to_oauth
    save_oauth_session
    authorize_url = token_class.authorize_url(auth_callback_url) do |request_token|
      save_auth_session_token(request_token) # only for oauth version 1
    end
    auth_controller.redirect_to authorize_url
  end
  
  # Step 3a: save our passed-parameters into the session,
  # so we can retrieve them after the redirect calls back
  def save_oauth_session
    # Store the class which is redirecting, so we can ensure other classes
    # don't get confused and attempt to use the response
    auth_session[:auth_request_class]         = self.class.name
  
    auth_session[:authentication_type]        = auth_params[:authentication_type]
    auth_session[:oauth_provider]             = auth_params[:oauth_provider]
    auth_session[:auth_method]                = "oauth"
    
    # Tell our rack callback filter what method the current request is using
    auth_session[:auth_callback_method]       = auth_controller.request.method
  end
  
  # Step 3b (if version 1.0 of oauth)
  def save_auth_session_token(request)
    # store token and secret
    auth_session[:oauth_request_token]        = request.token
    auth_session[:oauth_request_token_secret] = request.secret
  end
  
  def restore_attributes
  end
  
  # Step 4: on callback, run this method
  def authenticate_with_oauth
    # implemented in User and Session Oauth modules
  end
  
  # Step last, after the response
  # having lots of trouble testing logging and out multiple times,
  # so there needs to be a solid way to know when a user has messed up loggin in.
  def cleanup_oauth_session
    [:auth_request_class,
      :authentication_type,
      :auth_method,
      :auth_attributes,
      :oauth_provider,
      :auth_callback_method,
      :oauth_request_token,
      :oauth_request_token_secret
    ].each {|key| auth_session.delete(key)}
  end
    
end