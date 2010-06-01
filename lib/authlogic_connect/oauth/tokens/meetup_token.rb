# http://www.meetup.com/meetup_api/docs/#oauth
# protected resources: http://api.meetup.com
class MeetupToken < OauthToken
  
  key :user_id

  settings "http://www.meetup.com/"
    :request_token_path => "/oauth/request",
    :authorize_path     => "/authorize",
    :access_token_path  => "/oauth/access"

end
