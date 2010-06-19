class FoursquareToken < OauthToken
  
  key :user_id
  
  settings "http://api.foursquare.com",
    :request_token_url => "http://foursquare.com/oauth/request_token",
    :access_token_url => "http://foursquare.com/oauth/access_token",
    :authorize_url => "http://foursquare.com/oauth/authorize"
  
end
