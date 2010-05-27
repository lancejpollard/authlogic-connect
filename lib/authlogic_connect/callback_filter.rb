class AuthlogicConnect::CallbackFilter
  def initialize(app)
    @app = app
  end
  
  # this intercepts how the browser interprets the url.
  # so we override it and say,
  # "if we've stored a variable in the session called :auth_callback_method,
  # then convert that into a POST call so we re-call the original method"
  def call(env)
    if env["rack.session"].nil?
      raise "Make sure you are setting the session in Rack too!  Place this in config/application.rb"
    end
    unless env["rack.session"][:auth_callback_method].blank?
      env["REQUEST_METHOD"] = env["rack.session"].delete(:auth_callback_method).to_s.upcase
    end
    @app.call(env)
  end
end
