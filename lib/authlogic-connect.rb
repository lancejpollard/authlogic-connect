require 'active_record'
require "rubygems"
require 'authlogic'
require 'oauth'
require 'oauth2'

this = File.dirname(__FILE__)
library = "#{this}/authlogic_connect"

require "#{this}/open_id_authentication"
require "#{library}/ext"
require "#{library}/authlogic_connect"
require "#{library}/callback_filter"
require "#{library}/access_token"
require "#{library}/openid"
require "#{library}/oauth"
require "#{library}/common"
require "#{library}/engine" if defined?(Rails) && Rails::VERSION::MAJOR == 3

custom_models =   ["#{library}/access_token"]
custom_models +=  Dir["#{library}/oauth/tokens"]
custom_models +=  Dir["#{library}/openid/tokens"]

# Rails 3/2 config
load_path_method = ActiveSupport::Dependencies.respond_to?(:autoload_paths) ? :autoload_paths : :load_paths

custom_models.each do |path|
  $LOAD_PATH << path
  ActiveSupport::Dependencies.send(load_path_method) << path
end

# Rails 3beta4 backport
if defined?(ActiveSupport::HashWithIndifferentAccess)
  ActiveSupport::HashWithIndifferentAccess.class_eval do
    def symbolize_keys!
      symbolize_keys
    end
  end
end