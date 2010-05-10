module AuthlogicConnect::Oauth
  # This module is responsible for adding oauth
  # to the Authlogic::Session::Base class.
  module Session
    def self.included(base)
      puts "included Oauth in Session"
      base.class_eval do
        include InstanceMethods
      end
    end

    module InstanceMethods
      include Process

      def self.included(klass)
        klass.class_eval do
          validate :validate_by_oauth, :if => :authenticating_with_oauth?
        end
      end
      
      # Hooks into credentials so that you can pass a user who has already has an oauth access token.
      def credentials=(value)
        super
        values = value.is_a?(Array) ? value : [value]
        hash = values.first.is_a?(Hash) ? values.first.with_indifferent_access : nil
        self.record = hash[:priority_record] if !hash.nil? && hash.key?(:priority_record)
      end

      def record=(record)
        @record = record
      end

    private
      # Clears out the block if we are authenticating with oauth,
      # so that we can redirect without a DoubleRender error.
      def save_with_oauth(&block)
        puts "SAVE SESSION WITH OAUTH"
        puts "redirecting_to_oauth_server? #{redirecting_to_oauth_server?.to_s}"
        block = nil if redirecting_to_oauth_server?
        return block.nil?
      end
      
      def authenticating_with_oauth?
        return false unless oauth_provider
        
        # Initial request when user presses one of the button helpers
        initial_request = (controller.params && !controller.params[:login_with_oauth].blank?)
        # When the oauth provider responds and we made the initial request
        initial_response = (oauth_response && auth_session && auth_session[:oauth_request_class] == self.class.name)
        
        return initial_request || initial_response
      end
      
      def authenticate_with_oauth
        if @record
          self.attempted_record = record
        else
          # this generated token is always the same for a user!
          # this is searching with User.find ...
          # attempted_record is part of AuthLogic
          key = oauth_key_and_secret[:key]
          token = oauth_token.find_by_key(key, :include => [:user]) # some weird error if I leave out the include
          self.attempted_record = token.user
        end
        
        if !attempted_record
          errors.add_to_base("Could not find user in our database, have you registered with your oauth account?")
        end
      end
    end
  end
end