module AuthlogicConnect
  module Oauth
    # This module is responsible for adding oauth
    # to the Authlogic::Session::Base class.
    module Session
      def self.included(base)
        base.send :include, InstanceMethods
      end
      
      module InstanceMethods
        
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
      end
    end
  end
end
