# http://getsatisfaction.com/developers/oauth
class GetSatisfactionToken < OauthToken
  
  class << self
    def settings
      @settings ||= {
        :site => "http://getsatisfaction.com",
        :request_token_path => "/api/request_token",
        :authorize_url => "/api/authorize",
        :access_token_path => "/api/access_token"
      }
    end
  end
end