Dir["#{File.dirname(__FILE__)}/oauth/*"].each { |file| require file }

ActiveRecord::Base.send(:include, AuthlogicConnect::Oauth::User)
Authlogic::Session::Base.send(:include, AuthlogicConnect::Oauth::Session)

