module AuthlogicConnect
  module Mixins
    module Session
    
      def self.included(base)    
        base.validate :validate_passport, :if => lambda { Passport.authenticating?(:session) }
        base.send :include, InstanceMethods
      end
      
      module InstanceMethods
        
        def save(&block)
          block = nil if block_given? && Passport.process?
          result = super(&block)
          yield(result) unless block.nil?
          result
        end
        
        def validate_passport
          Passport.authenticate(self.record) do |token|
            if token
              if @record
                self.attempted_record = @record
              else
                self.attempted_record = klass.new
              end

              if attempted_record
                attempted_record.access_tokens << token
                attempted_record.save
              else
                errors.add(:base, "Could not find user in our database, have you registered with your oauth account?")
              end
            else
              errors.add("Passport validation error")
            end
          end
        end
      end
    end
  end
end
