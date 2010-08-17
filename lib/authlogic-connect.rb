require 'rubygems'
require 'active_record'
require 'authlogic'
require 'passport'

this = File.dirname(__FILE__)
library = "#{this}/authlogic_connect"
require "#{library}/openid"
require "#{library}/oauth"
require "#{library}/mixins"