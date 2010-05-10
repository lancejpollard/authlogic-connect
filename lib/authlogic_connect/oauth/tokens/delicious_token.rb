class DeliciousToken < OauthToken
  
  class << self
    def settings
      @settings ||= {
        :site => "http://api.del.icio.us",
        :realm => "yahooapis.com"
      }
    end
  end
  
end