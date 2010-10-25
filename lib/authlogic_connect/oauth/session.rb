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
          puts "//////////////////////////   OAUTH" 
          puts "//////////////////////////   OAUTH #{hash}" 
          puts "//////////////////////////   OAUTH.inspect #{hash.inspect}" 
          puts "//////////////////////////   hash[:key] #{hash[:key]}" 
          puts "//////////////////////////   hash[:token] #{hash[:token]}" 
          token = token_class.find_by_key_or_token(hash[:key], hash[:token], :include => [:user]) # some weird error if I leave out the include)
          if token
            self.attempted_record = token.user
          elsif auto_register?
            self.attempted_record = klass.new
            self.attempted_record.access_tokens << token_class.new(hash)
            
            puts "//////////////   FACEBOOK TOKEN???   #{self.attempted_record.get_token(:facebook)}"
            puts "//////////////   FACEBOOK TOKEN???   #{self.attempted_record.get_token(:facebook).inspect}"
            # If it's a facebook token lets look up the users email address
            if self.attempted_record.has_token?(:facebook)
              self.attempted_record.active_token = self.attempted_record.get_token(:facebook)
              facebook = JSON.parse(self.attempted_record.active_token.get("/me"))
              puts "//////////////   FACEBOOK DETAILS #{facebook.inspect}"
              puts "//////////////   FACEBOOK EMAIL #{facebook[:email]}"
              
              if facebook["email"]
                existing_user = klass.find_by_email(facebook["email"])
                puts "//////////////   FACEBOOK DETAILS YES YES YES YES #{existing_user} #{existing_user.inspect}"
                if existing_user
                  self.attempted_record = existing_user
                  self.attempted_record.access_tokens << token_class.new(hash)                  
                  puts "/////////   FACEBOOK HOLY SHIT IT's WORKING BEeeeeACH"
                end
              end
              
            end
            
            
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
