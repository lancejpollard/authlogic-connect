module AuthlogicConnect::Openid::Process

  include AuthlogicConnect::Openid::Variables
  
  def start_openid
    save_openid_session
    call_openid
  end
  
  def complete_openid
    restore_attributes
    call_openid
  end
  
  def call_openid
    options = {}
    options[:return_to] = auth_callback_url
    # this is called both on start and complete.
    # reason being, in the open_id_authentication library (where "authenticate_with_open_id" is defined),
    # it checks the rack session to find openid pareters, and knows whether we're at
    # start or complete
    auth_controller.send(:authenticate_with_open_id, openid_identifier, options) do |result, openid_identifier|
      complete_openid_transaction(result, openid_identifier)
      return true
    end
    return false
  end
  
  def complete_openid_transaction(result, openid_identifier)
    if result.unsuccessful?
      errors.add_to_base(result.message)
    end
    
    if Token.find_by_key(openid_identifier.normalize_identifier)
    else
      token = OpenidToken.new(:key => openid_identifier)
      self.tokens << token
      self.active_token = token
    end
  end
  
  # want to do this after the final save
  def cleanup_openid_session
    [:auth_attributes, :authentication_type, :auth_callback_method].each {|key| remove_session_key(key)}
    auth_session.each_key do |key|
      remove_session_key(key) if key.to_s =~ /^OpenID/
    end
  end
  
  def validate_by_openid
    if processing_authentication
      authentication_protocol(:openid, :start) || authentication_protocol(:openid, :complete)
      errors.add(:tokens, "had the following error: #{@openid_error}") if @openid_error
    end
  end
  
  def save_openid_session
    # Tell our rack callback filter what method the current request is using
    auth_session[:auth_callback_method]   = auth_controller.request.method
    auth_session[:auth_attributes]        = attributes_to_save
    auth_session[:authentication_type]    = auth_params[:authentication_type]
    auth_session[:auth_method]            = "openid"
  end
  
  def attributes_to_save
    {}
  end
  
  def restore_attributes
    # Restore any attributes which were saved before redirecting to the auth server
    self.attributes = auth_session[:auth_attributes] unless is_auth_session?
  end
  
end
