class NetflixToken < OauthToken
  
  key :user_id

  settings "http://api.netflix.com",
    :request_token_path => "/oauth/request_token",
    :access_token_path => "/oauth/access_token",
    :authorize_path => "/oauth/login"

end