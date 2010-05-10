# http://www.vimeo.com/api/docs/oauth
# http://www.vimeo.com/api/applications/new
class VimeoToken < OauthToken
  
  class << self
    def settings
      @settings ||= {
        :site => "http://vimeo.com",
        :authorize_url => "http://vimeo.com/oauth/authorize"
      }
    end
  end
end