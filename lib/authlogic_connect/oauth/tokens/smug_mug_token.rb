# http://wiki.smugmug.net/display/API/OAuth
class SmugMugToken < OauthToken
  
  class << self
    def settings
      @settings ||= {
        :site => "http://api.smugmug.com",
        :request_token_path => "/services/oauth/getRequestToken.mg",
        :authorize_url => "/services/oauth/authorize.mg",
        :access_token_path => "/services/oauth/getAccessToken.mg"
      }
    end
  end
end