require File.dirname(__FILE__) + '/test_helper.rb'

module AuthlogicConnect
  class UserTest < Test::Unit::TestCase
    context "User creation" do
      setup do
        @user = User.new(:login => "viatropos")
      end

      should "make sure we are loading the models" do
        assert_equal "viatropos", @user.login
      end
      
      context "responds to added oauth methods (our oauth api on the user)" do
        
        should "have 'tokens' method" do
          assert @user.respond_to?(:tokens)
          assert_equal [], @user.tokens
        end
        
        should "have 'active_token' method" do
          assert @user.respond_to?(:active_token)
          assert_equal nil, @user.active_token
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
        
        context "save the user without any parameters" do
          
          setup do
            @save_success = @user.save
          end
          
          should "be a valid save" do
            assert @save_success
          end
          
          should "not be using oauth" do
            assert_equal false, @user.using_oauth?
          end
          
          should "not be using openid" do
            assert_equal false, @user.using_openid?
          end
          
        end
        
        context "with oauth parameters" do
          
          setup do
            @user.auth_controller.params.merge!(:oauth_provider => "twitter")
            # mock token
            @token = OAuth::RequestToken.new("twitter", "key", "secret")
            @token.params = {
              :oauth_callback_confirmed => "true", 
              :oauth_token_secret=>"secret",
              :oauth_token=>"key"
            }
            @token.consumer = OAuth::Consumer.new("key", "secret",
              :site=>"http://twitter.com",
              :proxy=>nil,
              :oauth_version=>"1.0",
              :request_token_path=>"/oauth/request_token",
              :authorize_path=>"/oauth/authorize",
              :scheme=>:header,
              :signature_method=>"HMAC-SHA1",
              :authorize_url=>"http://twitter.com/oauth/authenticate",
              :access_token_path=>"/oauth/access_token"
            )
            @session_vars = [
              :authentication_type,
              :auth_request_class,
              :oauth_provider,
              :auth_callback_method
            ]
          end
          
          should "have an 'oauth_provider'" do
            assert @user.oauth_provider?
          end
          
          should "be an 'oauth_request'" do
            assert @user.oauth_request?
          end
          
          should "not be an 'oauth_response'" do
            assert_equal false, @user.oauth_response?
          end
          
          should "be using oauth" do
            assert @user.using_oauth?
          end
          
          should "not be using openid" do
            assert_equal false, @user.using_openid?
          end
          
          should "have the correct class (authentication_type == user)" do
            assert @user.correct_request_class?
          end
          
          should "realize we are authenticating_with_oauth?" do
            assert @user.authenticating_with_oauth?
          end
          
        end
        
        context "with openid parameters" do
          setup do
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
        end

      end
    end
    
  end
end
