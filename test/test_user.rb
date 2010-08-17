require File.dirname(__FILE__) + '/test_helper.rb'

module AuthlogicConnect
  class UserTest < Test::Unit::TestCase
    context "User creation" do
      setup do
        @user = User.new(:login => "viatropos")
        Authlogic::Session::Base.controller = controller
      end
      
      should "make sure we are loading the models" do
        assert_equal "viatropos", @user.login
      end
      
      context "responds to added oauth methods (our oauth api on the user)" do
        
        should "have 'access_tokens' method" do
          assert @user.respond_to?(:access_tokens)
          assert_equal [], @user.access_tokens
        end
        
      end
      
      context "with controller and session..." do
        
        setup do
          controller.params.merge!(:authentication_type => "user")
          Authlogic::Session::Base.controller = controller
        end
        
        should "have a valid controller" do
          assert @user.auth_controller
        end
        
        should "have auth_params" do
          assert @user.auth_params?
        end
        
        should "have an empty 'auth_session'" do
          assert @user.auth_session.empty?
          assert_equal false, @user.auth_session?
        end

      end
      
      context "save the user without any parameters" do
        
        setup do
          @save_success = @user.save
        end
        
        should "be a valid save" do
          assert @save_success
        end
        
        should "not be using oauth" do
          assert_equal false, @user.using_oauth?
          # using_oauth? == (oauth_request? || oauth_response? || stored_oauth_token_and_secret?)
          assert_equal false, @user.oauth_request?
          # oauth_request? == (auth_params? && oauth_provider?)
          assert_equal false, @user.auth_params?
          assert_equal false, @user.oauth_provider?
          assert_equal false, @user.oauth_response?
          # oauth_response? == (!oauth_response.nil? && auth_session? && auth_session[:auth_request_class] == self.class.name && auth_session[:auth_method] == "oauth")
          assert_equal false, !@user.oauth_response.nil?
#          assert_equal false, @user.auth_session?
          assert_equal false, @user.stored_oauth_token_and_secret?
        end
        
        should "not be using openid" do
          assert_equal false, @user.using_openid?
        end
        
      end
      
      context "user with required password field" do
        
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
