class TwitterToken < OauthToken
  
  key :user_id
  
  settings "https://api.twitter.com",
    :authorize_url => "https://api.twitter.com/oauth/authenticate"
  
end
