require 'rubygems'
require 'tempfile'
require 'test/unit'

require 'shoulda'
gem 'activerecord',  '~>3.0.0'
gem 'activesupport', '~>3.0.0'
gem 'actionpack',    '~>3.0.0'
require 'active_record'
require 'active_record/version'
require 'active_support'
require 'action_pack'
gem "ruby-openid"
gem 'rack-openid', '>=0.2.1'
gem "authlogic", :git => "git://github.com/odorcicd/authlogic.git", :branch => "rails3"
require 'authlogic'
gem "oauth"
gem "oauth2"

puts "Testing against version #{ActiveRecord::VERSION::STRING}"

begin
  require 'ruby-debug'
rescue LoadError => e
  puts "debugger disabled"
end

ROOT = File.join(File.dirname(__FILE__), '..')

def silence_warnings
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end

class Test::Unit::TestCase
  def setup
    silence_warnings do
      Object.const_set(:Rails, stub('Rails', :root => ROOT, :env => 'test'))
    end
  end
end

$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'authlogic-connect')

require File.join(ROOT, 'lib', 'authlogic-connect.rb')

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures") 
config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])