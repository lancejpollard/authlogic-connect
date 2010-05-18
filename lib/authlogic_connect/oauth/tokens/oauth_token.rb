class OauthToken < Token
  
  def client
    unless @client
      if oauth_version == 1.0
        @client = OAuth::AccessToken.new(self.consumer, self.key, self.secret)
      else
        @client = OAuth2::AccessToken.new(self.consumer, self.key)
      end
    end
    
    @client
  end
  
  def oauth_version
    self.class.oauth_version
  end
  
  def get(path, options = {})
    client.get(path)
  end
  
  class << self
    
    def version(value)
      @oauth_version = value
    end
    
    def oauth_version
      @oauth_version ||= 1.0
    end
    
    def consumer
      unless @consumer
        if oauth_version == 1.0
          @consumer = OAuth::Consumer.new(credentials[:key], credentials[:secret], config.merge(credentials[:options] || {}))
        else
          @consumer = OAuth2::Client.new(credentials[:key], credentials[:secret], config)
        end
      end
      
      @consumer
    end
    
    def request_token(token, secret)
      OAuth::RequestToken.new(consumer, token, secret)
    end
    
    def get_request_token(callback_url)
      consumer.get_request_token({:oauth_callback => callback_url}, config)
    end
    
    def get_access_token(oauth_verifier)
      request_token.get_access_token(:oauth_verifier => oauth_verifier)
    end
  end
  
end
