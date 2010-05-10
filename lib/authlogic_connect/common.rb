module AuthlogicConnect::Common
end

require File.dirname(__FILE__) + "/common/variables"
require File.dirname(__FILE__) + "/common/user"
require File.dirname(__FILE__) + "/common/session"

ActiveRecord::Base.send(:include, AuthlogicConnect::Common::User)
Authlogic::Session::Base.send(:include, AuthlogicConnect::Common::Session)
