# http://wiki.developer.myspace.com/index.php?title=Category:MySpaceID
# http://developerwiki.myspace.com/index.php?title=OAuth_REST_API_Usage_-_Authentication_Process
# http://developerwiki.myspace.com/index.php?title=How_to_Set_Up_a_New_Application_for_OpenID
class MyspaceToken < OauthToken
  
  settings "http://api.myspace.com", 
    :request_token_path => "/request_token",
    :authorize_path     => "/authorize",
    :access_token_path  => "/access_token"
  
end