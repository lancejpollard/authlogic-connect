# http://www.facebook.com/developers/apps.php
# http://developers.facebook.com/setup/
class FacebookToken < OauthToken
  
  class << self
    def settings
      @settings ||= {
        :site => "https://graph.facebook.com",
        :authorize_url => "https://graph.facebook.com/oauth/authorize",
        :oauth_version => "2.0",
        :scope => "email, offline_access"
      }
    end
    
    def oauth_version
      2.0
    end
  end
end