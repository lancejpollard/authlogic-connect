# http://www.vimeo.com/api/docs/oauth
# http://www.vimeo.com/api/applications/new
# http://vimeo.com/api/applications
class VimeoToken < OauthToken
  
  key do |access_token|
    body = JSON.parse(access_token.get("http://vimeo.com/api/v2/#{access_token.token}/info.json"))
    user_id = body.first["id"]
  end
  
  settings "http://vimeo.com",
    :request_token_path => "/oauth/request_token",
    :authorize_path     => "/oauth/authorize",
    :access_token_path  => "/oauth/access_token",
    :http_method        => "get",
    :scheme             => :query_string
  
end