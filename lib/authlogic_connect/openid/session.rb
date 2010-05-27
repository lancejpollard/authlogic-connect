module AuthlogicConnect::Openid
  # This module is responsible for adding all of the OpenID goodness to the Authlogic::Session::Base class.
  module Session
    # Add a simple openid_identifier attribute and some validations for the field.
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
      end
    end
    
    module InstanceMethods
      include AuthlogicConnect::Openid::Process
      
      def self.included(klass)
        klass.class_eval do
          validate :validate_openid_error
          validate :validate_by_openid, :if => :authenticating_with_openid?
        end
      end
      
      # Hooks into credentials so that you can pass an :openid_identifier key.
      def credentials=(value)
        super
        values = value.is_a?(Array) ? value : [value]
        hash = values.first.is_a?(Hash) ? values.first.with_indifferent_access : nil
        self.openid_identifier = hash[:openid_identifier] if !hash.nil? && hash.key?(:openid_identifier)
      end
      
      # Cleaers out the block if we are authenticating with OpenID, so that we can redirect without a DoubleRender
      # error.
      def save_with_openid(&block)
        block = nil if Token.find_by_key(openid_identifier.normalize_identifier)
        return block.nil?
      end
      
      private
        def authenticating_with_openid?
          attempted_record.nil? && errors.empty? && (!openid_identifier.blank? || (controller.params[:open_id_complete] && controller.params[:for_session]))
        end
        
        def auto_register?
          false
        end
        
        def validate_by_openid
          self.remember_me = auth_params[:remember_me] == "true" if auth_params.key?(:remember_me)
          token = Token.find_by_key(openid_identifier.normalize_identifier, :include => [:user])
          self.attempted_record = token.user if token
          if !attempted_record
            if auto_register?
              self.attempted_record = klass.new :openid_identifier => openid_identifier
              attempted_record.save do |result|
                if result
                  true
                else
                  false
                end
              end
            else
              errors.add(:openid_identifier, "did not match any users in our database, have you set up your account to use OpenID?")
            end
            return
          end
          controller.send(:authenticate_with_open_id, openid_identifier, :return_to => controller.url_for(:for_session => "1", :remember_me => remember_me?)) do |result, openid_identifier|
            if result.unsuccessful?
              errors.add_to_base(result.message)
              return
            end
            
          end
        end
        
        def validate_openid_error
          errors.add(:openid_identifier, @openid_error) if @openid_error
        end
    end
  end
end