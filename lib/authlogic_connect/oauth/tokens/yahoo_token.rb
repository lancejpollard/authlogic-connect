# https://developer.apps.yahoo.com/dashboard/createKey.html
# http://developer.yahoo.com/oauth/guide/oauth-accesstoken.html
class YahooToken < OauthToken
  
  version 2
  
  settings "https://api.login.yahoo.com",
    :request_token_path => '/oauth/v2/get_request_token',
    :access_token_path  => '/oauth/v2/get_token',
    :authorize_path     => '/oauth/v2/request_auth'
  
end