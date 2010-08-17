module AuthlogicConnect
  module Oauth
    module User
  
      def self.included(base)
        base.send :include, InstanceMethods
      end
  
      module InstanceMethods
        
        # Set up some simple validations
        def self.included(base)
          base.class_eval do
        
            # need these validation options if you don't want it to choke
            # on password length, which you don't need if you're using oauth
            validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_oauth?)
            validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_oauth?)
            validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_oauth?)
            validates_length_of_login_field_options validates_length_of_login_field_options.merge(:if => :validate_password_with_oauth?)
            validates_format_of_login_field_options validates_format_of_login_field_options.merge(:if => :validate_password_with_oauth?)
        
          end
        end
      end
    end
  end
end
