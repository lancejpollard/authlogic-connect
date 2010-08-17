#Dir["#{File.dirname(__FILE__)}/openid/*"].each { |file| require file unless File.directory?(file) }

#ActiveRecord::Base.send(:include, AuthlogicConnect::Openid::User)
#Authlogic::Session::Base.send(:include, AuthlogicConnect::Openid::Session)
