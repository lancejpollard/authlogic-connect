module AuthlogicConnect::Common::Variables
  include AuthlogicConnect::Common::State

  attr_reader :processing_authentication
  
  def auth_class
    is_auth_session? ? self.class : session_class
  end
  
  def auth_controller
    is_auth_session? ? controller : session_class.controller
  end
  
  def auth_params
    return nil unless auth_controller?
    auth_controller.params.symbolize_keys!
    auth_controller.params.keys.each do |key|
      auth_controller.params[key.to_s] = auth_controller.params.delete(key) if key.to_s =~ /^OpenID/
    end
    auth_controller.params
  end
  
  def auth_session
    return nil unless auth_controller?
    auth_controller.session.symbolize_keys!
    auth_controller.session.keys.each do |key|
      auth_controller.session[key.to_s] = auth_controller.session.delete(key) if key.to_s =~ /^OpenID/
    end
    auth_controller.session
  end
  
  def auth_callback_url(options = {})
    auth_controller.url_for({:controller => auth_controller.controller_name, :action => auth_controller.action_name}.merge(options))
  end
  
  # if we've said it's a "user" (registration), or a "session" (login)
  def auth_type
    from_session_or_params(:authentication_type)
  end
  
  # auth_params and auth_session attributes are all String!
  def from_session_or_params(attribute)
    return nil unless auth_controller?
    key = attribute.is_a?(Symbol) ? attribute : attribute.to_sym
    result = auth_params[key] if (auth_params && auth_params[key])
    result = auth_session[key] if (result.nil? || result.blank?)
    result
  end
  
  def add_session_key(key, value)
    
  end
  
  def remove_session_key(key)
    keys = key.is_a?(Symbol) ? [key, key.to_s] : [key, key.to_sym]
    keys.each {|k| auth_session.delete(k)}
  end
    
  # wraps the call to "save" (in yield).
  # reason being, we need to somehow not allow oauth/openid validations to run
  # when we don't have a block.  We can't know that using class methods, so we create
  # this property "processing_authentication", which is used in the validation method.
  # it's value is set to "block_given", which is the value of block_given?
  def authenticate_via_protocol(block_given = false, options = {}, &block)
    @processing_authentication = auth_controller? && block_given
    saved = yield start_authentication?
    @processing_authentication = false
    saved
  end
  
  # returns boolean
  def authentication_protocol(with, phase)
    returning(send("#{phase.to_s}_#{with.to_s}?")) do |ready|
      send("#{phase.to_s}_#{with.to_s}") if ready
    end if send("using_#{with.to_s}?")
  end
  
  # it only reaches this point once it has returned, or you
  # have manually skipped the redirect and save was called directly.
  def cleanup_authentication_session(options = {}, &block)
    unless (options.has_key?(:keep_session) && options[:keep_session])
      %w(oauth openid).each do |type|
        send("cleanup_#{type.to_s}_session")
      end
    end
  end
  
  def log(*methods)
    methods.each do |method|
      puts "#{method.to_s}: #{send(method).inspect}"
    end
  end
    
  def log_state
    log(:correct_request_class?)
    log(:using_oauth?, :start_oauth?, :complete_oauth?)
    log(:oauth_request?, :oauth_response?, :stored_oauth_token_and_secret?)
    log(:using_openid?, :start_openid?, :complete_openid?, :openid_request?, :openid_response?)
    log(:authenticating_with_openid?)
    log(:stored_oauth_token_and_secret)
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
  
  def auto_register?
    true
  end
  
end
