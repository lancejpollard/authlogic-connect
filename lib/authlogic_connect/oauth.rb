module AuthlogicConnect::Oauth
end

require File.dirname(__FILE__) + "/oauth/version"
require File.dirname(__FILE__) + "/oauth/process"
require File.dirname(__FILE__) + "/oauth/user"
require File.dirname(__FILE__) + "/oauth/session"
require File.dirname(__FILE__) + "/oauth/helper"

ActiveRecord::Base.send(:include, AuthlogicConnect::Oauth::User)
Authlogic::Session::Base.send(:include, AuthlogicConnect::Oauth::Session)
ActionController::Base.helper AuthlogicConnect::Oauth::Helper