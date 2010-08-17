# This class is the main api for the user.
# It is also required to properly sequence the save methods
# for the different authentication types (oauth and openid)
module AuthlogicConnect
  module Mixins
    module User
    
      def self.included(base)
        base.validate :validate_passport, :if => lambda { Passport.authenticating?(:user) }
        base.send :include, InstanceMethods
      end
  
      module InstanceMethods
        
        def self.included(base)
          base.class_eval do
            has_many :access_tokens, :as => :user, :class_name => "AccessToken", :dependent => :destroy
            accepts_nested_attributes_for :access_tokens
          end
        end
        
        def save(options = {}, &block)
          block = nil if block_given? && Passport.process?
          options[:validate] = true unless options.has_key?(:validate)
          result = super(options, &block)
          yield(result) unless block.nil?
          result
        end
        
        def validate_passport
          Passport.authenticate(self) do |token|
            if token
              access_tokens << token
            else
              errors.add("Passport validation error")
            end
          end
        end
        
        def update_attributes(attributes, &block)
          self.attributes = attributes
          save(:validate => true, &block)
        end
        
        def access_token(service)
          self.access_tokens.detect { |token| token.service == service.to_s }
        end

        def access_token?(service)
          access_token(service).blank?
        end
        
        # user.facebook_token
        # user.facebook_token?
        def method_missing(meth, *args, &block)
          if meth.to_s =~ /(\w+)_token(\?)?/
            service = $1
            return access_token?(service) unless $2.blank?
            return access_token(service)
          end

          super(meth, *args, &block)
        end
        
      end
    end
  end
end
