class TwitterToken < OauthToken
  
  class << self
    def settings
      @settings ||= {
        :site => "http://twitter.com",
        :authorize_url => "http://twitter.com/oauth/authenticate"
      }
    end
  end
end