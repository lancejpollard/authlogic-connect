module AuthlogicConnect::Common
  module Session
    
    def self.included(base)
      base.class_eval do
        include Variables
        include InstanceMethods
      end
    end
    
    module InstanceMethods
      
      # core save method coordinating how to save the session
      def save(&block)
        block_destroyed = false
        if authenticating_with_openid?
          block_destroyed = save_with_openid(&block)
        elsif authenticating_with_oauth?
          block_destroyed = save_with_oauth(&block)
        end
        block = nil if block_destroyed
        super(&block)
      end
    end
    
  end
end