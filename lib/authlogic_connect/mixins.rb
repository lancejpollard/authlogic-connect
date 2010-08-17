Dir["#{File.dirname(__FILE__)}/mixins/*"].each { |file| require file }

ActiveRecord::Base.send(:include, AuthlogicConnect::Mixins::User)
Authlogic::Session::Base.send(:include, AuthlogicConnect::Mixins::Session)
