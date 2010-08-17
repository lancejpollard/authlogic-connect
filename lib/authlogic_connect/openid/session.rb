module AuthlogicConnect
  module Openid
    # This module is responsible for adding all of the OpenID goodness to the Authlogic::Session::Base class.
    module Session
      # Add a simple openid_identifier attribute and some validations for the field.
      def self.included(base)
        base.send :include, InstanceMethods
      end
      
      module InstanceMethods
        
        # Hooks into credentials so that you can pass an :openid_identifier key.
        def credentials=(value)
          super
          values = value.is_a?(Array) ? value : [value]
          hash = values.first.is_a?(Hash) ? values.first.with_indifferent_access : nil
        end
      
        private
          
          def auto_register?
            false
          end
        
          def complete_openid_transaction(result, openid_identifier)
            if result.unsuccessful?
              errors.add_to_base(result.message)
            end
          
            token = AccessToken.find_by_key(openid_identifier.normalize_identifier, :include => [:user])
          
            self.attempted_record = token.user if token
          
            if !attempted_record
              if auto_register?
                self.attempted_record = base.new
                self.attempted_record.access_tokens << OpenidToken.new(:key => openid_identifier.normalize_identifier)
                self.attempted_record.save
              else
                auth_session[:openid_identifier] = openid_identifier
                errors.add(:user, "Could not find user in our database, have you registered with your openid account?")
              end
            end
          end
        
      end
    end
  end
end