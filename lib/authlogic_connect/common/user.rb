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
    # we will run the validations.
    # when you call 'current_user_session' in ApplicationController,
    # it leads to calling 'save' on this User object via "session.record.save",
    # from the 'persisting?' method.  So we don't want any of this to occur
    # when that save is called, and the only way to check currently is
    # to check if there is a block_given?
    def save(options = {}, &block)
      self.errors.clear
      # log_state
      options = {} if options == false
      options[:validate] = true unless options.has_key?(:validate)
      save_options = ActiveRecord::VERSION::MAJOR < 3 ? options[:validate] : options
      
      # kill the block if we're starting authentication
      authenticate_via_protocol(block_given?, options) do |redirecting|
        block = nil if redirecting
        # forces you to validate, only if a block is given
        result = super(save_options) # validate!
        unless block.nil?
          cleanup_authentication_session(options)
          yield(result)
        end
        result
      end
    end
    
  end
  
end
