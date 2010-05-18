module AuthlogicConnect
  class Engine < Rails::Engine
    engine_name :authlogic_connect
    
    initializer "authlogic_connect.authentication_hook" do |app|
      app.middleware.use AuthlogicConnect::CallbackFilter
      app.middleware.use OpenIdAuthentication
    end
    
    initializer "authlogic_connect.finalize", :after => "authlogic_connect.authentication_hook" do |app|
      OpenID::Util.logger = Rails.logger
      ActionController::Base.send :include, OpenIdAuthentication
    end
  end
end
