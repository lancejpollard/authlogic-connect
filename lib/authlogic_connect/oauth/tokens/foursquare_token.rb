class FoursquareToken < OauthToken
  
  key do |access_token|
    body = JSON.parse(access_token.get("/user.json").body)
    user_id = body['user']['id'].to_s
  end
  
  settings "http://api.foursquare.com/:api_version",
    :request_token_url  => "http://foursquare.com/oauth/request_token",
    :access_token_url   => "http://foursquare.com/oauth/access_token",
    :authorize_url      => "http://foursquare.com/oauth/authorize",
    :api_versions       => {1 => "v1", 2 => "v2"},
    :api_version        => 1
  
end
