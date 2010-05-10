# http://photobucket.com/developer/
# https://login.photobucket.com/developer/register
class PhotobucketToken < OauthToken
  
  class << self
    def settings
      @settings ||= {
        :site => "http://twitter.com",
        :authorize_url => "http://twitter.com/oauth/authenticate"
      }
    end
  end
end