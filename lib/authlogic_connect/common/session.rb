module AuthlogicConnect::Common
  module Session
    
    def self.included(base)    
      base.class_eval do
        include Variables
        include InstanceMethods
      end
    end
    
    module InstanceMethods
      
      # core save method coordinating how to save the session.
      # want to destroy the block if we redirect to a remote service, that's it.
      # otherwise the block contains the render methods we wan to use
      def save(&block)
        self.errors.clear
        # log_state
        authenticate_via_protocol(block_given?) do |redirecting|
          block = nil if redirecting
          result = super(&block)
          cleanup_authentication_session unless block.nil?
          result
        end
      end
      
    end
    
  end
end
