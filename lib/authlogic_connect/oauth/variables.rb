module AuthlogicConnect::Oauth
  module Variables
    
    # These are just helper variables
    def oauth_response
      auth_params && oauth_key
    end
    
    def oauth_key
      return nil unless auth_controller
      oauth_version == 1.0 ? auth_params[:oauth_token] : auth_params[:code]
    end
    
    def oauth_version
      oauth_token.oauth_version
    end
    
    def oauth_provider
      auth_session[:oauth_provider] || "facebook"
    end
    
    def oauth_consumer
      oauth_token.consumer
    end
    
    def oauth_token
      AuthlogicConnect.token(oauth_provider)
    end
  end
end
