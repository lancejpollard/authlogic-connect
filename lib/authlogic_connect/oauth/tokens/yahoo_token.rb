# https://developer.apps.yahoo.com/dashboard/createKey.html
# https://developer.apps.yahoo.com/projects
# http://developer.yahoo.com/oauth/guide/oauth-accesstoken.html
# http://developer.yahoo.com/oauth/guide/oauth-auth-flow.html
# http://code.google.com/apis/gadgets/docs/oauth.html
# http://developer.yahoo.com/social/rest_api_guide/web-services-guids.html
# A GUID identifies a person
# http://social.yahooapis.com/v1/me/guid
class YahooToken < OauthToken
  
  # http://social.yahooapis.com/v1/me/guid
  key :xoauth_yahoo_guid
  
  settings "https://api.login.yahoo.com",
    :request_token_path => '/oauth/v2/get_request_token',
    :access_token_path  => '/oauth/v2/get_token',
    :authorize_path     => '/oauth/v2/request_auth'
  
end
