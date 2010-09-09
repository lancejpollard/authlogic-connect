module AuthlogicConnect::Oauth
  # This module is responsible for adding oauth
  # to the Authlogic::Session::Base class.
  module Session
    def self.included(base)
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
      
      def complete_oauth_transaction
        if @record
          self.attempted_record = record
        else
          # this generated token is always the same for a user!
          # this is searching with User.find ...
          # attempted_record is part of AuthLogic
          hash = oauth_token_and_secret
          token = token_class.find_by_key_or_token(hash[:key], hash[:token], :include => [:user]) # some weird error if I leave out the include)
          if token
            token.update_attributes(:key => hash[:key], :token => hash[:token], :secret => hash[:secret])
            self.attempted_record = token.user
            self.attempted_record.oauth_login_callback(false) if self.attempted_record.respond_to?(:oauth_login_callback)
            self.attempted_record.save if self.attempted_record.changed?
          elsif auto_register?
            self.attempted_record = klass.new
            self.attempted_record.access_tokens << token_class.new(hash)
            self.attempted_record.oauth_login_callback(true) if self.attempted_record.respond_to?(:oauth_login_callback)
            self.attempted_record.save
          else
            auth_session[:_key] = hash[:key]
            auth_session[:_token] = hash[:token]
            auth_session[:_secret] = hash[:secret]
          end
        end

        if !attempted_record
          errors.add(:user, "Could not find user in our database, have you registered with your oauth account?")
        end
      end
    end
  end
end
