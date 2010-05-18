require 'active_record'
require "rubygems"
require 'authlogic'
require 'oauth'
require 'oauth2'

this = File.dirname(__FILE__)
library = "#{this}/authlogic_connect"

class Hash
  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        v.recursively_symbolize_keys!
      end
    end
    self
  end
end

class Array
  def recursively_symbolize_keys!
    self.each do |item|
      if item.is_a? Hash
        item.recursively_symbolize_keys!
      elsif item.is_a? Array
        item.recursively_symbolize_keys!
      end
    end
  end
end

module AuthlogicConnect
  KEY = "connect"
  
  class << self
    
    attr_accessor :config
    
    def config=(value)
      value.recursively_symbolize_keys!
      @config = value
    end
    
    def key(path)
      result = self.config
      path.to_s.split(".").each { |node| result = result[node.to_sym] if result }
      result
    end
    
    def credentials(service)
      key("#{KEY}.#{service.to_s}")
    end
    
    def services
      key(KEY)
    end
    
    def service_names
      services.keys.collect(&:to_s)
    end
    
    def include?(service)
      !credentials(service).nil?
    end
    
    def token(key)
      raise "can't find key '#{key.to_s}' in AuthlogicConnect.config" unless AuthlogicConnect.include?(key) and !key.to_s.empty?
      "#{key.to_s.camelcase}Token".constantize
    end
    
    def consumer(key)
      token(key).consumer
    end
  end
end

require "#{this}/open_id_authentication"
require "#{library}/callback_filter"
require "#{library}/token"
require "#{library}/openid"
require "#{library}/oauth"
require "#{library}/common"
require "#{library}/engine" if defined?(Rails) && Rails::VERSION::MAJOR == 3

custom_models =   ["#{library}/token"]
custom_models +=  Dir["#{library}/oauth/tokens"]
custom_models +=  Dir["#{library}/openid/tokens"]

custom_models.each do |path|
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
end