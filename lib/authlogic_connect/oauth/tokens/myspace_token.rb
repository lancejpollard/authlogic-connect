# http://wiki.developer.myspace.com/index.php?title=Category:MySpaceID
# http://developerwiki.myspace.com/index.php?title=OAuth_REST_API_Usage_-_Authentication_Process
# http://developerwiki.myspace.com/index.php?title=How_to_Set_Up_a_New_Application_for_OpenID
# http://developer.myspace.com/Modules/Apps/Pages/ApplyDevSandbox.aspx
# after you've signed up:
# http://developer.myspace.com/modules/apps/pages/createappaccount.aspx
# "Create a MySpaceID App"
# http://developer.myspace.com/modules/apps/pages/editapp.aspx?appid=188312&mode=create
# http://developer.myspace.com/Modules/APIs/Pages/OAuthTool.aspx
# http://developer.myspace.com/Community/forums/p/3626/15947.aspx
class MyspaceToken < OauthToken
  
  # http://wiki.developer.myspace.com/index.php?title=Portable_Contacts_REST_Resources
  key do |access_token|
    body = JSON.parse(access_token.get("/v2/people/@me/@self?format=json").body)
    id = body["entry"]["id"]
  end
  
  settings "http://api.myspace.com", 
    :request_token_path => "/request_token",
    :authorize_path     => "/authorize",
    :access_token_path  => "/access_token",
    :http_method        => "get",
    :scheme             => :query_string
  
end