module AuthlogicConnect::Oauth
  module Process

  private
    include AuthlogicConnect::Oauth::Variables

    def validate_by_oauth
      validate_email_field = false

      if oauth_response.blank?
        redirect_to_oauth
      else
        authenticate_with_oauth
      end
    end
    
    def redirecting_to_oauth_server?
      authenticating_with_oauth? && oauth_response.blank?
    end
    
    def redirect_to_oauth
      save_oauth_callback

      if oauth_version == 1.0
        request = oauth_token.get_request_token(oauth_callback_url)
        save_auth_session(request)
        auth_controller.redirect_to request.authorize_url
      else
        auth_controller.redirect_to oauth_consumer.web_server.authorize_url(
          :redirect_uri => oauth_callback_url,
          :scope => oauth_token.config[:scope]
        )
      end
    end
    
    def save_oauth_callback
      puts "save_oauth_callback"
      # Store the class which is redirecting, so we can ensure other classes
      # don't get confused and attempt to use the response
      auth_session[:oauth_request_class]        = self.class.name
      auth_session[:oauth_provider]             = auth_params[:oauth_provider]

      # Tell our rack callback filter what method the current request is using
      auth_session[:auth_callback_method]      = auth_controller.request.method
    end
    
    def save_auth_session(request)
      # store token and secret
      auth_session[:oauth_request_token]        = request.token
      auth_session[:oauth_request_token_secret] = request.secret
    end

    def oauth_callback_url
      auth_controller.url_for :controller => auth_controller.controller_name, :action => auth_controller.action_name
    end
    
    def request_token
      oauth_token.request_token(auth_session[:oauth_request_token], auth_session[:oauth_request_token_secret])
    end
    
    # in oauth 1.0, key = oauth_token, secret = oauth_secret
    # in oauth 2.0, key = code, secret = access_token
    def oauth_key_and_secret
      if oauth_version == 1.0
        result = request_token.get_access_token(:oauth_verifier => auth_params[:oauth_verifier])
        result = {:key => result.token, :secret => result.secret}
      else
        result = oauth_consumer.web_server.get_access_token(oauth_key, :redirect_uri => oauth_callback_url)
        result = {:key => result.token, :secret => oauth_key}
      end
      result
    end

    def generate_access_token
      if oauth_version == 1.0
        request_token.get_access_token(:oauth_verifier => auth_params[:oauth_verifier])
      else
        oauth_consumer.web_server.get_access_token(oauth_key, :redirect_uri => oauth_callback_url)
      end
    end
    
  end
end