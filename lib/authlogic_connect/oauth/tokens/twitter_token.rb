class TwitterToken < OauthToken
  
  key :user_id
  
  settings "http://api.twitter.com",
    :authorize_url => "http://api.twitter.com/oauth/authenticate"
  
end
