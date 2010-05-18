# http://developer.linkedin.com/docs/DOC-1008
# http://github.com/pengwynn/linkedin/tree/master/lib/linked_in/
class LinkedInToken < OauthToken
  
  settings "https://api.linkedin.com",
    :request_token_path => "/uas/oauth/requestToken",
    :access_token_path  => "/uas/oauth/accessToken",
    :authorize_path     => "/uas/oauth/authorize"
  
end
