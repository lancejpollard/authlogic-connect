module AuthlogicConnect::Openid
  module User
    def self.included(base)
      base.class_eval do
        add_acts_as_authentic_module(AuthlogicConnect::Openid::Process, :prepend)
        add_acts_as_authentic_module(InstanceMethods, :append)
      end
    end
    
    module InstanceMethods
      
      def self.included(base)        
        base.class_eval do
          validate :validate_by_openid, :if => :authenticating_with_openid?
          
          validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_openid?)
          validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_openid?)
          validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_openid?)
          validates_length_of_login_field_options validates_length_of_login_field_options.merge(:if => :validate_password_with_openid?)
          validates_format_of_login_field_options validates_format_of_login_field_options.merge(:if => :validate_password_with_openid?)
        end
      end
      
      def attributes_to_save
        attr_list = [:id, :password, crypted_password_field, password_salt_field, :persistence_token, :perishable_token, :single_access_token, :login_count, 
          :failed_login_count, :last_request_at, :current_login_at, :last_login_at, :current_login_ip, :last_login_ip, :created_at,
          :updated_at, :lock_version]
        attrs_to_save = attributes.clone.delete_if do |k, v|
          attr_list.include?(k.to_sym)
        end
        if self.respond_to?(:password) && self.respond_to?(:password_confirmation)
          attrs_to_save.merge!(:password => password, :password_confirmation => password_confirmation)
        end
        attrs_to_save
      end
    end
  end
end
