require "authlogic-connect-andrewacove"

# copied from open_id_authentication plugin on github

# this is the Rails 2.x equivalent.
# Rails 3 equivalent is in authlogic_connect/engine.rb
if Rails.version < '3'
  config.gem 'rack-openid', :lib => 'rack/openid', :version => '>=0.2.1'
end

require 'open_id_authentication'

config.middleware.use OpenIdAuthentication
config.middleware.use AuthlogicConnect::CallbackFilter

config.after_initialize do
  OpenID::Util.logger = Rails.logger
  ActionController::Base.send :include, OpenIdAuthentication
end
