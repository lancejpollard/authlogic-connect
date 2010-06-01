module AuthlogicConnect::Oauth::User
  
  def self.included(base)
    base.class_eval do
      # add_acts_as_authentic_module makes sure it is
      # only added to the user model, not all activerecord models.
      add_acts_as_authentic_module(InstanceMethods, :prepend)
    end
  end
  
  module InstanceMethods
    include AuthlogicConnect::Oauth::Process
    
    # Set up some simple validations
    def self.included(base)
      base.class_eval do
        
        validate :validate_by_oauth, :if => :authenticating_with_oauth?
        
        # need these validation options if you don't want it to choke
        # on password length, which you don't need if you're using oauth
        validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_oauth?)
        validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_oauth?)
        validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_oauth?)
        validates_length_of_login_field_options validates_length_of_login_field_options.merge(:if => :validate_password_with_oauth?)
        validates_format_of_login_field_options validates_format_of_login_field_options.merge(:if => :validate_password_with_oauth?)
        
      end
    end
    
    # user adds a few extra things to this method from Process
    # modules work like inheritance
    def save_oauth_session
      super
      auth_session[:auth_attributes]            = attributes.reject!{|k, v| v.blank? || !self.respond_to?(k)} unless is_auth_session?
    end
    
    def redirect_to_oauth
      return has_token?(oauth_provider) ? false : super
    end
    
    def restore_attributes
      # Restore any attributes which were saved before redirecting to the auth server
      self.attributes = auth_session[:auth_attributes]
    end
    
    # single implementation method for oauth.
    # this is called after we get the callback url and we are saving the user
    # to the database.
    # it is called by the validation chain.
    def complete_oauth_transaction
      token = token_class.new(oauth_token_and_secret)
      
      if has_token?(oauth_provider) || token_class.find_by_key_or_token(token.key, token.token)
        self.errors.add(:tokens, "you have already created an account using your #{token_class.service_name} account, so it")
      else
        self.access_tokens << token
        self.active_token = token
      end
    end
    
  end
end
