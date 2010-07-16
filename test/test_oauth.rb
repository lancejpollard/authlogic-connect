require File.dirname(__FILE__) + '/test_helper.rb'

module AuthlogicConnect
  class OauthTest < ActiveSupport::TestCase
    context "Oauth (with TwitterToken)" do
      setup do
        @user = User.new(:login => "viatropos")
        controller.params.merge!(:authentication_type => "user")
        Authlogic::Session::Base.controller = controller
        
        # this is the only thing the controller passes through for oauth
        @user.auth_controller.params.merge!(:oauth_provider => "twitter")
        
        # mock token
        @token = create_token
        
        @session_vars = [
          :authentication_type,
          :auth_request_class,
          :oauth_provider,
          :auth_callback_method
        ]
      end
      
      context "REQUEST (with TwitterToken)" do
        
        should "have an 'oauth_provider'" do
          assert_equal "twitter", @user.auth_params[:oauth_provider]
          assert_equal true, @user.oauth_provider?
          # session hasn't started yet
          assert_equal false, @user.auth_session?
        end

        should "be an 'oauth_request'" do
          assert_equal true, @user.oauth_request?
          # oauth_request? == (auth_params? && oauth_provider?)
          assert_equal true, @user.auth_params?
          assert_equal true, @user.oauth_provider?
        end

        should "not be an 'oauth_response'" do
          assert_equal false, @user.oauth_response?
          # oauth_response? == (!oauth_response.nil? && auth_session? && auth_session[:auth_request_class] == self.class.name && auth_session[:auth_method] == "oauth")
          assert_equal false, !@user.oauth_response.nil?
          assert_equal false, @user.auth_session?
          assert_equal false, @user.stored_oauth_token_and_secret?
        end

        should "be using oauth" do
          # all of the above too!
          assert @user.using_oauth?
        end
        
        should "start authentication" do
          assert_equal true, @user.start_authentication?
          # start_authentication? == (start_oauth? || start_openid?)
          assert_equal true, @user.start_oauth?
          # start_oauth == (authenticating_with_oauth? && !oauth_complete?)
          assert_equal true, @user.authenticating_with_oauth?
          # authenticating_with_oauth? == (correct_request_class? && using_oauth?)
          assert_equal true, @user.correct_request_class?
          assert_equal true, @user.using_oauth?
          assert_equal true, !@user.oauth_complete?          
        end
        
        should "not be using openid" do
          assert_equal false, @user.start_openid?
          assert_equal false, @user.using_openid?
          assert_equal false, @user.openid_request?
          # openid_request? == (!openid_identifier.blank? && auth_session[:auth_attributes].nil?)
          assert_equal false, @user.openid_response?
          # openid_response? == (auth_controller? && !auth_session[:auth_attributes].nil? && auth_session[:auth_method] == "openid")
        end

        should "have the correct class (authentication_type == user)" do
          assert_equal "user", @user.auth_params[:authentication_type]
          assert @user.correct_request_class?
        end

        should "realize we are authenticating_with_oauth?" do
          assert_equal true, @user.authenticating_with_oauth?
        end
      end
      
      context "SAVE" do
        setup do
          @user.save
          request_token = {:token => "a_token", :secret => "a_secret"}
          # mock out like we've saved the data just before the first redirect
          @user.save_oauth_session
          @user.auth_session[:oauth_request_token]        = request_token[:token]
          @user.auth_session[:oauth_request_token_secret] = request_token[:secret]
        end
        
        should "save without a block" do
          assert_equal true, @user.authenticating_with_oauth?
          assert_equal true, @user.valid?
        end
        
        should "still be an oauth request" do
          assert_equal true, @user.oauth_request?
        end
        
        context "RESPONSE (with TwitterToken)" do
          setup do
            @key_and_secret = {:key => "a_key", :secret => "a_secret", :token => "a_token"}
            @user.auth_controller.params.merge!(:oauth_token => @key_and_secret[:token])
            TwitterToken.stubs(:get_token_and_secret).returns(@key_and_secret)
          end

          should "have TwitterToken" do
            assert_equal TwitterToken, @user.token_class
            assert 1.0, @user.token_class.oauth_version
          end
          
          should "have oauth token" do
            assert @user.auth_params
            assert_equal true, @user.auth_params?
            assert_equal "a_token", @user.oauth_token
          end
          
          should "not be an 'oauth_request'" do
            assert_equal true, @user.auth_params?
            assert_equal true, @user.oauth_provider?
            assert_equal false, @user.oauth_response.blank?
            #assert_equal false, @user.oauth_request?
            # need a better way of checking this!
          end

          should "be an 'oauth_response'" do
            assert_equal true, !@user.oauth_response.nil?
            assert_equal true, @user.auth_session?
            assert_equal true, (@user.auth_session[:auth_request_class] == @user.class.name)
            assert_equal true, (@user.auth_session[:auth_method] == "oauth")
            assert_equal true, @user.oauth_response?
          end

          should "be using oauth" do
            assert_equal true, @user.using_oauth?
          end
          
          should "not be using openid" do
            assert_equal false, @user.using_openid?
          end

          should "not be an 'openid_request'" do
            assert_equal false, @user.using_openid?
          end

          should "not be an 'openid_response" do
            assert_equal false, @user.using_openid?
          end

          teardown do
            #TwitterToken.unstub(:get_token_and_secret)
          end
        end
      end
      
      teardown do
        @token = nil
        @user = nil
        controller.params.clear
        controller.session.clear
        Authlogic::Session::Base.controller = controller
      end
    end
    
    context "tokens" do
      setup do
        @token = TwitterToken.new
      end
      
      should "be version 1 since it's twitter" do
        assert_equal 1.0, @token.oauth_version
      end
      
      should "return a new consumer with each call" do
        first_consumer = @token.consumer
        second_consumer = @token.consumer
        assert_not_equal first_consumer, second_consumer
      end
    end
  end
end
