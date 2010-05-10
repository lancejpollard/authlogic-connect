class OauthToken < AuthToken
  
  # Main client for interfacing with remote service. Override this to use
  # preexisting library eg. Twitter gem.
  def client
    @client ||= OAuth::AccessToken.new(self.class.consumer, token, secret)
  end
  
  def simple_client
    @simple_client ||= SimpleClient.new(OAuth::AccessToken.new(self.class.consumer, token, secret))
  end
  
  def oauth_version
    self.class.oauth_version
  end
  
  class << self
    
    def oauth_version
      1.0
    end
    
    def settings
      @settings ||= {}
    end
    
    def consumer
      @consumer ||= OAuth::Consumer.new(credentials[:key], credentials[:secret], settings.merge(credentials[:options] || {}))
    end
    
    def client
      OAuth2::Client.new(credentials[:key], credentials[:secret], settings)
    end
    
    def request_token(token, secret)
      OAuth::RequestToken.new(consumer, token, secret)
    end
    
    def get_request_token(callback_url)
      consumer.get_request_token({:oauth_callback => callback_url}, settings)
    end
    
    def get_access_token(oauth_verifier)
      request_token.get_access_token(:oauth_verifier => oauth_verifier)
    end
  end
  
end
