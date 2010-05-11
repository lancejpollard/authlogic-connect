class AuthlogicConnect::CallbackFilter
  def initialize(app)
    @app = app
  end
  
  def call(env)
    if env["rack.session"].nil?
      raise "Make sure you are setting the session in Rack too!  Place this in config/application.rb"
    end
    unless env["rack.session"][:oauth_callback_method].blank?
      env["REQUEST_METHOD"] = env["rack.session"].delete(:oauth_callback_method).to_s.upcase
    end
    @app.call(env)
  end
end