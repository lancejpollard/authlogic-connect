require "authlogic_connect"
require "oauth_callback_filter"

# Throw callback rack app into the middleware stack
ActionController::Dispatcher.middleware = ActionController::MiddlewareStack.new do |m|
  ActionController::Dispatcher.middleware.each do |klass|
    m.use klass
  end
  m.use OauthCallbackFilter
end

custom_models = Dir["#{File.dirname(__FILE__)}/../lib/authlogic_connect/oauth/tokens"]
custom_models +=Dir["#{File.dirname(__FILE__)}/../lib/authlogic_connect/openid/tokens"]
custom_models.each do |path|
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
end