# http://www.vimeo.com/api/docs/oauth
# http://www.vimeo.com/api/applications/new
class VimeoToken < OauthToken
  
  settings "http://vimeo.com",
    :authorize_url => "http://vimeo.com/oauth/authorize"
  
end