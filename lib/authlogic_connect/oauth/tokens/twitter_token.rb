class TwitterToken < OauthToken
  
  key :user_id
  
  settings "http://twitter.com",
    :authorize_url => "http://twitter.com/oauth/authenticate"
  
end