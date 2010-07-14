require "rubygems"
require "ruby-debug"
gem 'test-unit'
require "test/unit"
require 'active_support'
require 'active_support/test_case'
require "active_record"
require "active_record/fixtures"
require 'action_controller'
require 'shoulda'
require 'mocha'

require File.dirname(__FILE__) + '/libs/database'
require File.dirname(__FILE__) + '/../lib/authlogic-connect' unless defined?(AuthlogicConnect)
require File.dirname(__FILE__) + '/libs/user'
require File.dirname(__FILE__) + '/libs/user_session'
require 'authlogic/test_case'

# A temporary fix to bring active record errors up to speed with rails edge.
# I need to remove this once the new gem is released. This is only here so my tests pass.
unless defined?(::ActiveModel)
  class ActiveRecord::Errors
    def [](key)
      value = on(key)
      value.is_a?(Array) ? value : [value].compact
    end
  end
end

AuthlogicConnect.config = {
  :default => "twitter",
  :connect => {
    :twitter => {
      :key => "my_key",
      :secret => "my_secret",
      :headers => {
        "User-Agent" => "Safari",
        "MyApp-Version" => "1.2"
      },
      :api_version => 1
    },
    :facebook => {
      :key => "my_key",
      :secret => "my_secret"
    },
    :foursquare => {
      :key => "my_key",
      :secret => "my_secret"
    },
    :google => {
      :key => "my_key",
      :secret => "my_secret"
    },
    :yahoo => {
      :key => "my_key",
      :secret => "my_secret"
    },
    :vimeo => {
  
    }
  }
}

# want to add a "method" property!
Authlogic::TestCase::MockRequest.class_eval do
  def method
    "POST"
  end
end

module ControllerHelpers
  def controller_name
    "users"
  end
  
  def action_name
    "create"
  end
  
  def url_for(options = {})
    p = []
    options.each do |k,v|
      p << "#{k}=#{v}"
    end
    p = "?#{p.join("&")}"
    url = "http://localhost:3000/users#{p}"
  end
  
  def session=(value)
    @session = value
  end
end
Authlogic::ControllerAdapters::AbstractAdapter.send(:include, ControllerHelpers)

Authlogic::CryptoProviders::AES256.key = "myafdsfddddddddddddddddddddddddddddddddddddddddddddddd"

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = File.dirname(__FILE__) + "/fixtures"
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = false
  fixtures :all
  setup :activate_authlogic
  
  def create_token
    token = OAuth::RequestToken.new("twitter", "key", "secret")
    token.params = {
      :oauth_callback_confirmed => "true", 
      :oauth_token_secret => "secret",
      :oauth_token => "key"
    }
    token.consumer = OAuth::Consumer.new("key", "secret",
      :site => "http://twitter.com",
      :proxy => nil,
      :oauth_version => "1.0",
      :request_token_path => "/oauth/request_token",
      :authorize_path => "/oauth/authorize",
      :scheme => :header,
      :signature_method => "HMAC-SHA1",
      :authorize_url => "http://twitter.com/oauth/authenticate",
      :access_token_path => "/oauth/access_token"
    )
    token
  end
  
  private
    def password_for(user)
      case user
      when users(:ben)
        "benrocks"
      when users(:zack)
        "zackrocks"
      end
    end
    
    def http_basic_auth_for(user = nil, &block)
      unless user.blank?
        controller.http_user = user.login
        controller.http_password = password_for(user)
      end
      yield
      controller.http_user = controller.http_password = nil
    end
    
    def set_cookie_for(user, id = nil)
      controller.cookies["user_credentials"] = {:value => user.persistence_token, :expires => nil}
    end
    
    def unset_cookie
      controller.cookies["user_credentials"] = nil
    end
    
    def set_params_for(user, id = nil)
      controller.params["user_credentials"] = user.single_access_token
    end
    
    def unset_params
      controller.params["user_credentials"] = nil
    end
    
    def set_request_content_type(type)
      controller.request_content_type = type
    end
    
    def unset_request_content_type
      controller.request_content_type = nil
    end
    
    def set_session_for(user, id = nil)
      controller.session["user_credentials"] = user.persistence_token
      controller.session["user_credentials_id"] = user.id
    end
    
    def unset_session
      controller.session["user_credentials"] = controller.session["user_credentials_id"] = nil
    end
end
