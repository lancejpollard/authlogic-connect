module AuthlogicConnect::Openid::Variables
  include AuthlogicConnect::Openid::State
  
  # openid_provider = "blogger", "myopenid", etc.
  # openid_identifier = "viatropos.myopenid.com", etc.
  # openid_key = "viatropos"
#  def openid_attributes
#    [:openid_provider, :openid_identifier, :openid_key]
#  end
  
  def openid_identifier
    auth_params[:openid_identifier] if auth_params?
  end
  
  def openid_provider
    from_session_or_params(:openid_provider) if auth_controller?
  end
  
end