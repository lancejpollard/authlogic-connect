# http://wiki.developer.myspace.com/index.php?title=Category:MySpaceID
class MyspaceToken < OauthToken
  
  class << self
    def settings
      @settings ||= {
        :site => "https://www.google.com", 
        :request_token_path => "/accounts/OAuthGetRequestToken",
        :authorize_path => "/accounts/OAuthAuthorizeToken",
        :access_token_path => "/accounts/OAuthGetAccessToken"
      }
    end
  end
end