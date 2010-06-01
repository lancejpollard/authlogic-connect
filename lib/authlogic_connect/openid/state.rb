# all these methods must return true or false
module AuthlogicConnect::Openid::State

  # 1. to call
  def openid_request?
    !openid_identifier.blank? && auth_session[:auth_attributes].nil?
  end
  
  def openid_identifier?
    openid_request?
  end
  
  def openid_provider?
    
  end
  
  # 2. from call
  # better check needed
  def openid_response?
    auth_controller? && !auth_session[:auth_attributes].nil? && auth_session[:auth_method] == "openid"
  end
  alias_method :openid_complete?, :openid_response?
  
  # 3. either to or from call
  # this should include more!
  # we know we are using open id if:
  #   the params passed in have "openid_identifier"
  def using_openid?
    auth_controller? && (openid_request? || openid_response?)
  end
  
  def authenticating_with_openid?
    auth_controller? && auth_class.activated? && using_openid?
  end
  
  def start_openid?
    authenticating_with_openid? && !openid_response?
  end

  def complete_openid?
    openid_complete?
  end
  
  def validate_password_with_openid?
    !using_openid? && require_password?
  end
  
end