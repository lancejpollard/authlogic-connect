module AuthlogicConnect::Common::Variables
  include AuthlogicConnect::Common::State
  
  def auth_controller
    is_auth_session? ? controller : session_class.controller
  end
  
  def auth_session
    auth_controller.session.symbolize_keys!
    auth_controller.session.keys.each do |key|
      auth_controller.session[key.to_s] = auth_controller.session.delete(key) if key.to_s =~ /^OpenID/
    end
    auth_controller.session
  end
  
  def auth_params
    auth_controller.params.symbolize_keys!
    auth_controller.params.keys.each do |key|
      auth_controller.params[key.to_s] = auth_controller.params.delete(key) if key.to_s =~ /^OpenID/
    end
    auth_controller.params
  end
  
  def auth_callback_url(options = {})
    auth_controller.url_for({:controller => auth_controller.controller_name, :action => auth_controller.action_name}.merge(options))
  end
  
  # if we've said it's a "user" (registration), or a "session" (login)
  def auth_type
    from_session_or_params(:authentication_type)
  end
  
  # auth_params and auth_session attributes are all String!
  def from_session_or_params(by)
    key = by.is_a?(Symbol) ? by : by.to_sym
    result = auth_params[key] if (auth_params && auth_params[key])
    result = auth_session[key] if result.blank? # might be null here too
    result
  end
  
  # because user and session are so closely tied together, I am still
  # uncertain as to how they are saved.  So this makes sure if we are
  # logging in, it must be saving the session, otherwise the user.
  def correct_request_class?
    if is_auth_session?
      auth_type.to_s == "session"
    else
      auth_type.to_s == "user"
    end
  end
  
  def add_session_key(key, value)
    
  end
  
  # because we may need to store 6+ session variables, all with pretty lengthy names,
  # might as well just tinify them.
  # just an idea
  def optimized_session_key(key)
    @optimized_session_keys ||= {
      :auth_request_class         => :authcl,
      :authentication_method      => :authme,
      :authentication_type        => :authty,
      :oauth_provider             => :authpr,
      :auth_callback_method       => :authcb,
      :oauth_request_token        => :authtk,
      :oauth_request_token_secret => :authsc,
      :auth_attributes            => :authat
    }
    @optimized_session_keys[key]
  end
  
end
