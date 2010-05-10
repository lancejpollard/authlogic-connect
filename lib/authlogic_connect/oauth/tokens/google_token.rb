# http://code.google.com/apis/accounts/docs/OAuth.html
# http://code.google.com/apis/accounts/docs/RegistrationForWebAppsAuto.html
# http://googlecodesamples.com/oauth_playground/
# Scopes:
# Analytics         https://www.google.com/analytics/feeds/ 
# Google Base       http://www.google.com/base/feeds/       
# Book Search       http://www.google.com/books/feeds/      
# Blogger           http://www.blogger.com/feeds/           
# Calendar          http://www.google.com/calendar/feeds/   
# Contacts          http://www.google.com/m8/feeds/         
# Documents List    http://docs.google.com/feeds/           
# Finance           http://finance.google.com/finance/feeds/
# GMail             https://mail.google.com/mail/feed/atom
# Health            https://www.google.com/health/feeds/
# H9                https://www.google.com/h9/feeds/
# Maps              http://maps.google.com/maps/feeds/
# OpenSocial        http://www-opensocial.googleusercontent.com/api/people/
# orkut             http://www.orkut.com/social/rest
# Picasa Web        http://picasaweb.google.com/data/
# Sidewiki          http://www.google.com/sidewiki/feeds/
# Sites             http://sites.google.com/feeds/
# Spreadsheets      http://spreadsheets.google.com/feeds/
# Webmaster Tools   http://www.google.com/webmasters/tools/feeds/
# YouTube           http://gdata.youtube.com
class GoogleToken < OauthToken
  
  class << self
    def settings
      @settings ||= {
        :site => "https://www.google.com", 
        :request_token_path => "/accounts/OAuthGetRequestToken",
        :authorize_path => "/accounts/OAuthAuthorizeToken",
        :access_token_path => "/accounts/OAuthGetAccessToken",
        :scope => "https://www.google.com/m8/feeds/"
      }
    end
  end
end