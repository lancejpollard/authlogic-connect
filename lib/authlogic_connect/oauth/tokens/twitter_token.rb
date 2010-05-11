class TwitterToken < OauthToken
  
  settings "http://twitter.com",
    :authorize_url => "http://twitter.com/oauth/authenticate"
  
end