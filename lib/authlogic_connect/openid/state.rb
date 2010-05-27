# all these methods must return true or false
module AuthlogicConnect::Openid::State
    # 1. to call
    def openid_request?
      !openid_identifier.blank?
    end
    
    def openid_identifier?
      openid_request?
    end
    
    def openid_provider?
      
    end
    
    # 2. from call
    # better check needed
    def openid_response?
      !auth_session[:auth_attributes].nil? && auth_session[:auth_method] == "openid"
    end
    alias_method :openid_complete?, :openid_response?
    
    # 3. either to or from call
    # this should include more!
    # we know we are using open id if:
    #   the params passed in have "openid_identifier"
    def using_openid?
      openid_request? || openid_response?
    end
    
    def authenticating_with_openid?
      session_class.activated? && using_openid?
    end
    
    def allow_openid_redirect?
      authenticating_with_openid?
    end
    
    def redirecting_to_openid_server?
      allow_openid_redirect? && !authenticate_with_openid
    end
    
    def validate_password_with_openid?
      !using_openid? && require_password?
    end
    
end