module AuthlogicConnect::Oauth
  module User
    def self.included(base)
      base.class_eval do
        add_acts_as_authentic_module(InstanceMethods, :prepend)
      end
    end
    
    module InstanceMethods
      include Process
      # Set up some simple validations
      def self.included(base)
        base.class_eval do
          has_many :tokens, :class_name => "AuthToken", :dependent => :destroy
          belongs_to :active_token, :class_name => "AuthToken", :dependent => :destroy
          accepts_nested_attributes_for :tokens, :active_token
          
          validate :validate_by_oauth, :if => :authenticating_with_oauth?
          
          # need these validation options if you don't want it to choke
          # on password length, which you don't need if you're using oauth
          validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_oauth?)
          validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_oauth?)
          validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_oauth?)
          validates_length_of_login_field_options validates_length_of_login_field_options.merge(:if => :validate_password_with_oauth?)
          validates_format_of_login_field_options validates_format_of_login_field_options.merge(:if => :validate_password_with_oauth?)
        end

        # email needs to be optional for oauth
        base.validate_email_field = false
      end
      
      def update_attributes(attributes, &block)
        self.attributes = attributes
        save(true, &block)
      end
      
      # NEED TO GIVE A BLOCK
      def save_with_oauth(perform_validation = true, &block)
        if perform_validation && block_given? && redirecting_to_oauth_server?
          # Save attributes so they aren't lost during the authentication with the oauth server
          auth_session[:authlogic_oauth_attributes] = attributes.reject!{|k, v| v.blank?}
          redirect_to_oauth
          return false
        end
        return true
      end
      
    protected
    
      def using_oauth?
        !oauth_token.blank?
      end
      
      def validate_password_with_oauth?
        !using_oauth? && require_password?
      end
      
      def authenticating_with_oauth?
        return false unless oauth_provider
        # Initial request when user presses one of the button helpers
        (auth_params && !auth_params[:register_with_oauth].blank?) ||
        # When the oauth provider responds and we made the initial request
        (oauth_response && auth_session && auth_session[:oauth_request_class] == self.class.name)
      end

      def authenticate_with_oauth
        # Restore any attributes which were saved before redirecting to the oauth server
        self.attributes = auth_session.delete(:authlogic_oauth_attributes)
        token = AuthlogicConnect.token(oauth_provider).new(oauth_key_and_secret)
        if AuthToken.find_by_key(token.key)
          self.errors.add("you have already created an account using your #{oauth_token.service_name} account, so it")
        else
          self.tokens << token
          self.active_token = token
        end
      end

    end
  end
end