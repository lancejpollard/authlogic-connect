require 'active_record'
require 'authlogic'
require 'oauth'
require 'oauth2'

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
  VERSION = "0.0.1"
  
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
      key("services.#{service.to_s}")
    end

    def include?(service)
      !credentials(service).nil?
    end
    
    def token(key)
      throw Error unless AuthlogicConnect.include?(key) and !key.to_s.empty?
      "#{key.to_s.camelcase}Token".constantize
    end
    
    def consumer(key)
      token(key).consumer
    end
  end
end

require File.dirname(__FILE__) + "/authlogic_connect/openid"
require File.dirname(__FILE__) + "/authlogic_connect/oauth"
require File.dirname(__FILE__) + "/authlogic_connect/common"