require File.dirname(__FILE__) + '/test_helper.rb'

module AuthlogicConnect
  class OpenIdTest < Test::Unit::TestCase
    context "OpenId" do
      setup do
        @user = User.new(:login => "viatropos")
        controller.params.merge!(:authentication_type => "user")
        Authlogic::Session::Base.controller = controller
        @user.auth_controller.params.merge!(:openid_identifier => "viatropos.myopenid.com")
        @session_vars = [
          :authentication_type,
          :auth_request_class,
          :openid_identifier,
          :auth_callback_method
        ]
      end
      
      should "have an 'openid_identifier'" do
        assert_equal true, @user.openid_identifier?
      end
      
      should "be an 'openid_request'" do
        assert @user.openid_request?
      end
      
      should "not be an 'openid_response'" do
        assert_equal false, @user.openid_response?
      end
      
      should "be using openid" do
        assert @user.using_openid?
      end
      
      should "not be using oauth" do
        assert_equal false, @user.using_oauth?
      end
      
      should "have the correct class (authentication_type == user)" do
        assert @user.correct_request_class?
      end
      
      should "realize we are authenticating_with_openid?" do
        assert @user.authenticating_with_openid?
      end
      
      context "and 'save_with_openid', manually checking each step" do
        
        setup do
          # mock save
          # this, and the whole redirect process happens
          # but we'll just assume we saved the session data and got the redirect back
          @user.save_openid_session
          @user.save(:skip_redirect => true, :keep_session => true) do
            "I'm the block you want"
          end
          # copy to test controller
          @user.auth_session.each do |key, value|
            @user.auth_controller.session[key] = value
          end
        end
        
        teardown do
          @user.destroy
        end
        
      end
      
      teardown do
        @user = nil
        controller.params.clear
        controller.session.clear
        Authlogic::Session::Base.controller = controller
      end
    end
  end
end
