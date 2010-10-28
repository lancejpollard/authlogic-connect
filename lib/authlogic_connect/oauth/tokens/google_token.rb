# http://code.google.com/apis/accounts/docs/OAuth_ref.html
# http://code.google.com/apis/accounts/docs/OpenID.html#settingup
# http://code.google.com/apis/accounts/docs/OAuth.html
# http://code.google.com/apis/accounts/docs/RegistrationForWebAppsAuto.html
# http://www.manu-j.com/blog/add-google-oauth-ruby-on-rails-sites/214/
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
  
   settings "https://www.google.com",
     :request_token_path => "/accounts/OAuthGetRequestToken",
     :authorize_path     => "/accounts/OAuthAuthorizeToken",
     :access_token_path  => "/accounts/OAuthGetAccessToken",
     :scope              => "https://www.googleapis.com/auth/userinfo#email"

   key do |access_token|
     body = JSON.parse(access_token.get("https://www.googleapis.com/userinfo/email?alt=json").body)
     email = body["data"]["email"]
   end
   
end
