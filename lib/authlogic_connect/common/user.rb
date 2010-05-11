module AuthlogicConnect::Common
  module User
    
    def self.included(base)
      base.class_eval do
        add_acts_as_authentic_module(Variables, :prepend)
        add_acts_as_authentic_module(InstanceMethods, :append)
      end
    end
    
    module InstanceMethods
      
      def connected_services
        @connected_services ||= self.tokens.collect{|t| t.service_name.to_s}
      end
      
      # core save method coordinating how to save the user
      def save(perform_validation = true, &block)
        status = true
        if authenticating_with_openid?
          status = save_with_openid(perform_validation, &block)
        elsif authenticating_with_oauth?
          status = save_with_oauth(perform_validation, &block)
        end
        if status
          result = super
          yield(result) if block_given?
          result
        end
        status
      end
      
      def validate_password_with_oauth?
        !using_openid? && super
      end
      
      def validate_password_with_openid?
        !using_oauth? && super
      end
      
    end
    
  end
end