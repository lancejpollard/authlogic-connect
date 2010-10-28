# http://getsatisfaction.com/developers/oauth
class GetSatisfactionToken < OauthToken
  
  settings "http://getsatisfaction.com",
    :request_token_path => "/api/request_token",
    :authorize_url      => "/api/authorize",
    :access_token_path  => "/api/access_token"
  
end
