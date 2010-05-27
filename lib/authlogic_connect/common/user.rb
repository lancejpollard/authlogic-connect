# This class is the main api for the user.
# It is also required to properly sequence the save methods
# for the different authentication types (oauth and openid)
module AuthlogicConnect::Common::User
    
  def self.included(base)
    base.class_eval do
      add_acts_as_authentic_module(InstanceMethods, :append)
      add_acts_as_authentic_module(AuthlogicConnect::Common::Variables, :prepend)
    end
  end
  
  module InstanceMethods
    
    def self.included(base)
      base.class_eval do
        has_many :tokens, :class_name => "Token", :dependent => :destroy
        belongs_to :active_token, :class_name => "Token", :dependent => :destroy
        accepts_nested_attributes_for :tokens, :active_token
      end
    end
    
    def authenticated_with
      @authenticated_with ||= self.tokens.collect{|t| t.service_name.to_s}
    end
    
    def authenticated_with?(service)
      self.tokens.detect{|t| t.service_name.to_s == service.to_s}
    end
    
    def update_attributes(attributes, &block)
      self.attributes = attributes
      save(:validate => true, &block)
    end
    
    def has_token?(service_name)
      !get_token(service_name).nil?
    end
    
    def get_token(service_name)
      self.tokens.detect {|i| i.service_name.to_s == service_name.to_s}
    end
    
    # core save method coordinating how to save the user.
    # we dont' want to ru validations based on the 
    # authentication mission we are trying to accomplish.
    # instead, we just return save as false.
    # the next time around, when we recieve the callback,
    # we will run the validations
    def save(options = {}, &block)
      # debug_user_save_pre(options, &block)
      options = {} if options == false
      unless options[:skip_redirect] == true
        return false if remotely_authenticating?(&block)
      end
      # forces you to validate, maybe get rid of if needed,
      # but everything depends on this
      if ActiveRecord::VERSION::MAJOR < 3
        result = super(true) # validate!
      else
        result = super(options.merge(:validate => true))
      end
      # debug_user_save_post
      yield(result) if block_given? # give back to controller
      
      cleanup_auth_session if result && !(options.has_key?(:keep_session) && options[:keep_session])
      
      result
    end
    
    def remotely_authenticating?(&block)
      return redirecting_to_oauth_server? if using_oauth? && block_given?
      return redirecting_to_openid_server? if using_openid?
      return false
    end
    
    # it only reaches this point once it has returned, or you
    # have manually skipped the redirect and save was called directly.
    def cleanup_auth_session
      cleanup_oauth_session
      cleanup_openid_session
    end
    
    def validate_password_with_oauth?
      !using_openid? && super
    end
    
    def validate_password_with_openid?
      !using_oauth? && super
    end
    
    # test methods for dev/debugging, commented out by default
    def debug_user_save_pre(options = {}, &block)
      puts "USER SAVE "
      puts "block_given? #{block_given?.to_s}"
      puts "using_oauth? #{using_oauth?.to_s}"
      puts "using_openid? #{using_openid?.to_s}"
      puts "authenticating_with_oauth? #{authenticating_with_oauth?.to_s}"
      puts "authenticating_with_openid? #{authenticating_with_openid?.to_s}"
      puts "validate_password_with_oauth? #{validate_password_with_oauth?.to_s}"
      puts "validate_password_with_openid? #{validate_password_with_openid?.to_s}"
      puts "!using_openid? && require_password? #{(!using_openid? && require_password?).to_s}"
    end
    
    def debug_user_save_post
      puts "ERRORS: #{errors.full_messages}"
      puts "using_oauth? #{using_oauth?.to_s}"
      puts "using_openid? #{using_openid?.to_s}"
      puts "validate_password_with_oauth? #{validate_password_with_oauth?.to_s}"
      puts "validate_password_with_openid? #{validate_password_with_openid?.to_s}"
    end
    
  end
  
end
