require File.dirname(__FILE__) + '/../test_helper.rb'

class UsersControllerTest < ActionController::TestCase

  tests UsersController

  context "when signed out" do
    # setup { sign_out }

    context "on GET to #new" do
      
      setup { get :new }

      should "do something???" do
        puts "REQUEST: #{@user.inspect}"
      end
      
    end
    
  end
end
