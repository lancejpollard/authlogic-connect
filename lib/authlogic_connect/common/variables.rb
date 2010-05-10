module AuthlogicConnect::Common
  module Variables
    
    def auth_controller
      is_auth_session? ? controller : session_class.controller
    end
    
    def auth_session
      auth_controller.session
    end
    
    def auth_params
      auth_controller.params
    end
    
    def is_auth_session?
      self.is_a?(Authlogic::Session::Base)
    end
    
  end
end