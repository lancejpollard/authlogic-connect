module AuthlogicConnect::Openid
  module User
    def self.included(base)
      base.class_eval do
        add_acts_as_authentic_module(InstanceMethods, :prepend)
      end
    end
    
    module InstanceMethods

      def self.included(base)
        return if !base.column_names.include?("openid_identifier")
        
        base.class_eval do
          validates_uniqueness_of :openid_identifier, :scope => validations_scope, :if => :using_openid?
          validate :validate_openid
          validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_openid?)
          validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_openid?)
          validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_openid?)
          validates_length_of_login_field_options validates_length_of_login_field_options.merge(:if => :validate_password_with_openid?)
          validates_format_of_login_field_options validates_format_of_login_field_options.merge(:if => :validate_password_with_openid?)
        end
      end
      
      def openid_identifier=(value)
        write_attribute(:openid_identifier, value.blank? ? nil : value.to_s.normalize_identifier)
        reset_persistence_token if openid_identifier_changed?
      rescue Exception => e
        @openid_error = e.message
      end
      
      def save_with_openid(perform_validation = true, &block)
        return false if perform_validation && block_given? && authenticating_with_openid? && !authenticating_with_openid
        return true
      end
      
      protected
        
        def validate_openid
          errors.add(:openid_identifier, "had the following error: #{@openid_error}") if @openid_error
        end
        
        def using_openid?
          respond_to?(:openid_identifier) && !auth_params[:openid_identifier].blank?
        end
        
        def openid_complete?
          auth_session[:openid_attributes]
        end
        
        def authenticating_with_openid?
          session_class.activated? && ((using_openid?) || openid_complete?)
        end
        
        def validate_password_with_openid?
          !using_openid? && require_password?
        end
        
        def authenticating_with_openid
          @openid_error = nil
          if !openid_complete?
            # Tell our rack callback filter what method the current request is using
            auth_session[:auth_callback_method]   = auth_controller.request.method
            auth_session[:openid_attributes]      = attributes_to_save
          else
            self.attributes                       = auth_session.delete(:openid_attributes)
          end
          
          options = {}
          options[:return_to] = auth_controller.url_for(:for_model => "1", :controller => "users", :action => "create")
          auth_controller.send(:authenticate_with_open_id, openid_identifier, options) do |result, openid_identifier, registration|
            if result.unsuccessful?
              @openid_error = result.message
            else
              self.openid_identifier = openid_identifier
            end
            return true
          end
          return false
        end
        
        def attributes_to_save
          attrs_to_save = attributes.clone.delete_if do |k, v|
            [:id, :password, crypted_password_field, password_salt_field, :persistence_token, :perishable_token, :single_access_token, :login_count, 
              :failed_login_count, :last_request_at, :current_login_at, :last_login_at, :current_login_ip, :last_login_ip, :created_at,
              :updated_at, :lock_version].include?(k.to_sym)
          end
          attrs_to_save.merge!(:password => password, :password_confirmation => password_confirmation)
        end
    end
  end
end