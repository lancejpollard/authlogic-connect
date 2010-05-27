# http://developer.linkedin.com/docs/DOC-1008
# https://www.linkedin.com/secure/developer
# http://github.com/pengwynn/linkedin/tree/master/lib/linked_in/
class LinkedInToken < OauthToken
  
  key do |access_token|
    body = access_token.get("https://api.linkedin.com/v1/people/~:(id)").body
    id = body.gsub("<id>([^><]+)</id>", "\\1") # so we don't need to also import nokogiri
    id
  end
  
  settings "https://api.linkedin.com",
    :request_token_path => "/uas/oauth/requestToken",
    :access_token_path  => "/uas/oauth/accessToken",
    :authorize_path     => "/uas/oauth/authorize",
    :http_method        => "get",
    :scheme             => :query_string
  
end
