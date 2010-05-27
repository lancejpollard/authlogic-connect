module AuthlogicConnect::Openid::Process

  include AuthlogicConnect::Openid::Variables
  
  # want to do this after the final save
  def cleanup_openid_session
    [:auth_attributes, :authentication_type, :auth_callback_method].each {|key| auth_session.delete(key)}
    auth_session.each_key do |key|
      auth_session.delete(key) if key.to_s =~ /^OpenID/
    end
  end
  
  def validate_by_openid
    errors.add(:tokens, "had the following error: #{@openid_error}") if @openid_error
  end
  
  def save_openid_session
    # Tell our rack callback filter what method the current request is using
    auth_session[:auth_callback_method]   = auth_controller.request.method
    auth_session[:auth_attributes]        = attributes_to_save
    auth_session[:authentication_type]    = auth_params[:authentication_type]
    auth_session[:auth_method]            = "openid"
  end
  
  def restore_attributes
    # Restore any attributes which were saved before redirecting to the auth server
    self.attributes = auth_session[:auth_attributes]
  end
  
end