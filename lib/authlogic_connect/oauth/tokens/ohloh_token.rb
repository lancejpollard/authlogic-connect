# https://www.ohloh.net/
# http://www.ohloh.net/api/oauth
class OhlohToken < OauthToken
  
  key :user_id

  settings "http://www.ohloh.net"

end
