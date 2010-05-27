module AuthlogicConnect::Oauth::Variables
  include AuthlogicConnect::Oauth::State
  
  # this doesn't do anything yet, just to show what variables
  # we need from the form
  def oauth_variables
    [:oauth_provider]
  end
    
  # this comes straight from either the params or session.
  # it is required for most of the other accessors in here
  def oauth_provider
    from_session_or_params(:oauth_provider)
  end
  
  # next is "token_class", which is found from the oauth_provider key.
  # it is the OauthToken subclass, such as TwitterToken, which we
  # use as the api for accessing oauth and saving the response to the database for a user.
  def token_class
    AuthlogicConnect.token(oauth_provider) unless oauth_provider.blank?
  end
  
  # This should go...
  def oauth_response
    auth_params && oauth_token
  end
  
  # the token from the response parameters
  def oauth_token
    return nil unless token_class
    oauth_version == 1.0 ? auth_params[:oauth_token] : auth_params[:code]
  end
  
  # the version of oauth we're using.  Accessed from the OauthToken subclass
  def oauth_version
    token_class.oauth_version
  end
  
  # the Oauth gem consumer, whereby we can make requests to the server
  def oauth_consumer
    token_class.consumer
  end
  
  # this is a thick method.
  # it gives you the final key and secret that we will store in the database
  def oauth_token_and_secret
    token_class.get_token_and_secret(
      :token          => auth_session[:oauth_request_token],
      :secret         => oauth_version == 1.0 ? auth_session[:oauth_request_token_secret] : oauth_token,
      :oauth_verifier => auth_params[:oauth_verifier],
      :redirect_uri   => auth_callback_url
    )
  end
  
end
