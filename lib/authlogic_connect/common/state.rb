# This class holds query/state variables common to oauth and openid
module AuthlogicConnect::Common::State
  
  def auth_controller?
    !auth_controller.blank?
  end

  def auth_params?
    auth_controller? && !auth_params.blank?
  end
  
  def auth_session?
    !auth_session.blank?
  end
  
  def is_auth_session?
    self.is_a?(Authlogic::Session::Base)
  end
  
  def start_authentication?
    start_oauth? || start_openid?
  end
  
  def validate_password_with_oauth?
    !using_openid? && super
  end
  
  def validate_password_with_openid?
    !using_oauth? && super
  end
  
  # because user and session are so closely tied together, I am still
  # uncertain as to how they are saved.  So this makes sure if we are
  # logging in, it must be saving the session, otherwise the user.
  def correct_request_class?
    return false unless auth_params?
    
    if is_auth_session?
      auth_type.to_s == "session"
    else
      auth_type.to_s == "user"
    end
  end
  
end
