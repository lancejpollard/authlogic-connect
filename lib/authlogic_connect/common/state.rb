# This class holds query/state variables common to oauth and openid
module AuthlogicConnect::Common::State
  
  def auth_session?
    !auth_session.blank?
  end
  
  def auth_params?
    !auth_params.blank?
  end
  
  def is_auth_session?
    self.is_a?(Authlogic::Session::Base)
  end
  
end