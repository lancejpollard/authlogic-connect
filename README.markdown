# Authlogic Connect

Authlogic Connect is an extension of the Authlogic library to add extensive Oauth and OpenID support. With Authlogic Connect, it's very easy to allow users to login through any of the 30+ authentication providers out there.  You shouldn't be reinventing the wheel anyways.

There are 3 ways you can allow your users to login with Authlogic Connect:

1. Clicking an Oauth Provider
2. Clicking an OpenID Provider and entering in their username
3. Manually typing in a full OpenID address

All of that is easier than creating a new account and password.

## Install and use

### 1. Install Authlogic Connect

    sudo gem install authlogic-connect

### 2. Add the gem dependencies in your config:

Rails 2.3.x: `config/environment.rb`

    config.gem "json"
    config.gem "authlogic"
    config.gem "oauth"
    config.gem "oauth2"
    config.gem "authlogic-connect"

Rails 3: `Gemfile`

    gem "ruby-openid"
    gem "rack-openid", ">=0.2.1", :require => "rack/openid"
    gem "authlogic", :git => "git://github.com/odorcicd/authlogic.git", :branch => "rails3"
    gem "oauth"
    gem "oauth2"
    gem "authlogic-connect"
    
### 2b.  Add the `OpenIdAuthentication.store`

Do to "some strange problem":http://github.com/openid/ruby-openid/issues#issue/1 I have yet to really understand, Rails 2.3.5 doesn't like when `OpenIdAuthentication.store` is null, which means it uses the "in memory" store and for some reason fails.

So as a fix, add these at the end of your `config/environment.rb` files:

In development mode:

    OpenIdAuthentication.store = :file
    
In production (on Heroku primarily)

    OpenIdAuthentication.store = :memcache

### 3. Add the Migrations

See the [Rails 2 Example](http://github.com/viatropos/authlogic-connect-example-rails2) and [Rails 3 Example](http://github.com/viatropos/authlogic-connect-example) projects to see what you need.  Will add a generator sometime.

Files needed are:

- models: User, UserSession
- controllers: UsersController, UserSessionsController, ApplicationController
- migrations: create\_users, create\_sessions, create\_tokens
- initializers: config/authlogic.example.yml, config/initializers/authlogic_connect_config.rb
- routes
    
### 4. Configure your keys

In `config/initializers/authlogic_connect_config.rb`, write your keys and secrets for each service you would like to support.  You have to manually go to the websites and register with the service provider (list of those links coming soon, in token classes for now).

    AuthlogicConnect.config = {
      :default => "facebook",
      :connect => {
        :twitter => {
          :key => "my_key",
          :secret => "my_secret",
          :label => "Twitter"
        },
        :facebook => {
          :key => "my_key",
          :secret => "my_secret",
          :label => "Facebook"
        },
        :google => {
          :key => "my_key",
          :secret => "my_secret",
          :label => "Google"
        },
        :yahoo => {
          :key => "my_key",
          :secret => "my_secret",
          :label => "Yahoo"
        },
        :vimeo => {
      
        }
      }
    }

### 5. Make sure you save your objects properly

Because of the redirects involved in Oauth and OpenID, you MUST pass a block to the `save` method in your UsersController and UserSessionsController:

    @user_session.save do |result|
      if result
        flash[:notice] # "Login successful!"
        redirect_back_or_default account_url
      else
        render :action => :new
      end
    end

You should save your `@user` objects this way as well, because you also want the user to authenticate with OAuth.

If we don't use the block, we will get a DoubleRender error. This lets us skip that entire block and send the user along their way without any problems.
  
### 6. Add Parameters to Forms in your Views

    <%# oauth_register_button :value => "Register with Twitter" %>
    <%# oauth_login_button :value => "Login with Twitter" %>

Check out the example projects to see exactly what's required.  These aren't totally useful yet.  Their job is to just send the right parameters to authlogic-connect.

### 7. Create Custom Tokens (if they don't already exist)

Here's an example of the FacebookToken for Oauth

    class FacebookToken < OauthToken

      version 2.0

      settings "https://graph.facebook.com",
        :authorize_url => "https://graph.facebook.com/oauth/authorize",
        :scope         => "email, offline_access"

    end
    
If there is an Oauth/OpenID service you need, let me know, or fork/add/push and I will integrate it into the project and add you to the list.

## Examples

These are examples of what you can get from a User.  Code is placed in controller for demo purposes, it should be abstracted into the model.

### API

User model has the following public accessors and methods.  This example assumes:

- You've associated your Google, OpenID, and Twitter accounts with this app.
- You're currently logged in via Google.

Inside the `show` method in a controller...

    def show
      @user = @current_user
      
      puts @user.tokens #=> [
        #<OpenidToken id: 12, user_id: 9, type: "OpenidToken", key: "http://my-openid-login.myopenid.com/", token: nil, secret: nil, active: nil, created_at: "2010-05-24 14:52:19", updated_at: "2010-05-24 14:52:19">,
        #<TwitterToken id: 13, user_id: 9, type: "TwitterToken", key: "my-twitter-id-123", token: "twitter-token", secret: "twitter-secret", active: nil, created_at: "2010-05-24 15:03:05", updated_at: "2010-05-24 15:03:05">,
        #<GoogleToken id: 14, user_id: 9, type: "GoogleToken", key: "my-email@gmail.com", token: "google-token", secret: "google-secret", active: nil, created_at: "2010-05-24 15:09:04", updated_at: "2010-05-24 15:09:04">]
          
      puts @user.tokens.length #=> 3
      
      # currently logged in with...
      puts @user.active_token #=> #<GoogleToken id: 14, user_id: 9, type: "GoogleToken", key: "my-email@gmail.com", token: "google-token", secret: "google-secret", active: nil, created_at: "2010-05-24 15:09:04", updated_at: "2010-05-24 15:09:04">
        
      puts @user.authenticated_with #=> ["twitter", "openid", "google"]
      puts @user.authenticated_with?(:twitter) #=> true
      puts @user.authenticated_with?(:facebook) #=> false
      
      puts @user.has_token?(:google) #=> true
      
      puts @user.get_token(:google) #=> #<GoogleToken id: 14, user_id: 9, type: "GoogleToken", key: "my-email@gmail.com", token: "google-token", secret: "google-secret", active: nil, created_at: "2010-05-24 15:09:04", updated_at: "2010-05-24 15:09:04">
      
      # change active_token
      @user.active_token = @user.get_token(:twitter)
      puts @user.active_token #=> #<TwitterToken id: 13, user_id: 9, type: "TwitterToken", key: "my-twitter-id-123", token: "twitter-token", secret: "twitter-secret", active: nil, created_at: "2010-05-24 15:03:05", updated_at: "2010-05-24 15:03:05">
      
      # access oauth api
      @twitter = @user.active_token
      @twitter_profile = JSON.parse(@twitter.get("/account/verify_credentials.json").body) #=> twitter api stuff
      # ...
    end

### Get Facebook Data

If they've associated their Facebook account with your site, you can access Facebook data.

    def show
      @user = @current_user
      token = @user.active_token # assuming this is FacebookToken
      facebook = JSON.parse(token.get("/me"))
      @profile = {
        :id     => facebook["id"],
        :name   => facebook["name"],
        :photo  => "https://graph.facebook.com/#{facebook["id"]}/picture",
        :link   => facebook["link"],
        :title  => "Facebook"
      }
      @profile = @user.profile
    end

## Supported Providers

### Oauth

- Twitter
- Facebook
- Google

### OpenID

- MyOpenID

Lists of all known providers here:

- [Oauth Providers](http://wiki.oauth.net/ServiceProviders)
- [OpenID Providers](http://en.wikipedia.org/wiki/List_of_OpenID_providers)
- [More OpenID](http://openid.net/get-an-openid/)

## Oauth vs. OpenID

There is a big but subtle difference between Oauth and OpenID:  Oauth is NOT a login protocol.  OpenID IS.

You should use Oauth when you want to be able to access and/or manipulate data on behalf of the user.  If all you want is authentication, OpenID is best.  However, if you want to login through Twitter or Facebook, you _have_ to use Oauth (forget Facebook Connect, too complicated).

An example would be using Google and Oauth.  With Google and Oauth, the user can grant you rights to "access the gmail contacts" for example, and you can get a list of their contacts.  That requires that your app is authorized, which requires they grant access via Oauth.  This is kinda strange though, because why does a login app need to access your google contacts?  It doesn't.  That's why we should use OpenID in this case.  But we can still use Oauth... continuing...

The problem with the Google Contacts Oauth example is that when you get the Oauth Access Token, Google doesn't give you any data, so you can't say "the 'guy who just logged in's email is abc@gmail.com, save that to the database".  That's where OpenID would shine.

If you want to use Oauth for logging in, you must get back some unique key to identify the user by.  The best options are something like email, username, or some unique id.  This is accomplished in the `GoogleToken` oauth class by passing a block to the `key` class method:

    key do |access_token|
      body = JSON.parse(access_token.get("https://www.google.com/m8/feeds/contacts/default/full?alt=json&max-results=0").body)
      email = body["feed"]["author"].first["email"]["$t"] # $t is some weird google json thing
    end
    
That hack lets us use Oauth to get the email address of the user, which we need if we want to somehow find the account for a user who has logged out

The confusing thing is that Twitter allows you to login with Oauth, it's one of the few it seems.  This is because Twitter sends back the `user_id` and `screen_name`, allowing you to pretend the user logged in.  Google doesn't send that.  Which means you have to make an _additional_ call to the service, if you're using Oauth.  If you're using OpenID, that's specifically for login so you're going to get back email/name/etc.

## Helpful links

*	<b>Authlogic:</b> [http://github.com/binarylogic/authlogic](http://github.com/binarylogic/authlogic)
*	<b>Authlogic Connect Example Project:</b> [http://github.com/viatropos/authlogic-connect-example](http://github.com/viatropos/authlogic-connect-example)
*	<b>Live example with Twitter and Facebook using Rails 3:</b> [http://authlogic-connect.heroku.com](http://authlogic-connect.heroku.com)
* <b>Rails 2.3.5 Example:</b> [http://github.com/viatropos/authlogic-connect-example-rails2](http://github.com/viatropos/authlogic-connect-example-rails2)
* **Rubygems Repository:** [http://rubygems.org/gems/authlogic-connect](http://rubygems.org/gems/authlogic-connect)

## The Flow

- Controller calls `save`
- Save checks to see what type of authentication we're going to use
  - methods called `authenticating_with_x?` sees if its service is in use
    - called twice, once before, and once after, redirect
  - it does this by checking if the session and parameters have certain variables defined.
- Save calls `save_with_x`, which either:
  - performs the initial redirect, or
  - on response from the service, retrieves attributes and saves the user
- If first round (hasn't yet redirected):
  - Saves important data into the session
  - Specifies callback url based on controller name and action
  - Redirects to remote service
  - User clicks "accept!"
  - Redirects back to callback url
- If second round (redirect callback url):
  - Still processing service (`authenticating_with_oauth?` for example)
  - Instantiates new User, Session, or Token, or all 3 if they are brand new
  - Validates User and Session
    - You don't want to validate any password/email if you're using these services,
      so they are all skipped
    - Need to validate keys
  - Save user
- Finish block, render page

### Note about the redirect process

When you make a request to one of these services, it responds with a GET request.  But assuming we have made the request through a `create` method (`UsersController#create` for `/register`, `UserSessionsController#create` for `/login`), we want that GET to be a POST.

This is accomplished by adding a property called `auth_callback_method` to the session when the original request is made.  It says "POST", or whatever the translation is from the controller method that was called.

Then a Rack Middleware filter converts the GET return request from the authentication service into POST.  This forces it to run back through the `create` method.  Check out [`AuthlogicConnect::CallbackFilter`](http://github.com/viatropos/authlogic-connect/blob/master/lib/authlogic_connect/callback_filter.rb) for details.  Or search "Rack Middleware".

## Project Goals

1. It should require the end user ONE CLICK to create an account with your site.
2. It should not depend on Javascript
3. It should be enhanced by Javascript
4. You should never have to touch the User/Session model/controller/migration if you are a just looking to get up and running quickly.
5. You should be able to plugin ruby libraries that wrap an api, such as TwitterAuth via `@user.twitter`, and LinkedIn via `@user.linked_in`.  Just because it's that easy.

### Tests

This only has a few unit tests.  Enough to make sure the methods are returning what we are expecting.

It should have Functional and Integration tests, using the Authlogic Connect example projects.  If any of you guys know of an easy way to set that up, I'd love to know.  Send me a github message :).

Goal:

- Test Framework: [Shoulda](http://github.com/thoughtbot/shoulda)
- Autotest with Shoulda
- Testing style like [Paperclip Tests](http://github.com/thoughtbot/paperclip/tree/master/test/)
- Rails 2.3+ and Rails 3 Compatability

### TODO

- If the user bails out in the middle of a login session, there needs to be a mechanism that knows how to reset their session.
- If the openid is filled out, and then the user clicks Twitter oauth, it should know that it should log them in via twitter.  This can only really be done by javascript.  But what should take precedence?  The thing that requires no typing: oauth.  So oauth should be checked first on save.
- Add rememberme functionality correctly.  Right now I think it remembers you by default.
- Login should work without having to access the remote service again.
- If I create new user with Twitter or Google, then logout, I can login through twitter no problem.  However, I cannot login through Google.  This is because google returns new tokens, so I can't find it in the database.  How do I find it?  Also, if you go and revoke access to twitter (go to your twitter profile on twitter.com, click "settings", and revoke access to app) after you've created an account, and you try to login, same problem.  This is because tokens are regenerated.  NEED CONFIRMATION SCREEN
- If the user has only created an account with say Twitter, then logs out, if they try to login with google, it should ask if they have a different account.  How should this work?

OAuth is for accessing remote information.  It doesn't always give you data about the user.  OpenID on the other hand gives you all the info you need for login.

## Helpful References for Rails 3

- [Rails 3 Initialization Process](http://ryanbigg.com/guides/initialization.html)
- [Rails 3 Plugins - Part 1, Big Picture](http://www.themodestrubyist.com/2010/03/01/rails-3-plugins---part-1---the-big-picture/)
- [Rails 3 Plugins - Part 2, Writing an Engine](http://www.themodestrubyist.com/2010/03/05/rails-3-plugins---part-2---writing-an-engine/)
- [Rails 3 Plugins - Part 3, Initializers](http://www.themodestrubyist.com/2010/03/16/rails-3-plugins---part-3---rake-tasks-generators-initializers-oh-my/)
- [Using Gemspecs as Intended](http://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)

## Parameters

should look like this:

Params from form:

    {"authentication_type"=>"user", "submit"=>"Register", "openid_identifier"=>"", "oauth_provider"=>"twitter"}
    
Session just before redirect:

    {"authentication_type"=>"user", "oauth_request_token"=>"token_key", "session_id"=>"session_hash", "auth_callback_method"=>"POST", "auth_attributes"=>{"login_count"=>0}, "oauth_request_token_secret"=>"token_secret", "auth_request_class"=>"User", "auth_method"=>"oauth", "oauth_provider"=>"twitter"}
    
## Details

The regular OAuth process is a four-step sequence:

1. ask for a "request" token.
2. ask for the token to be authorized, which triggers user approval.
3. exchange the authorized request token for an "access" token.
4. use the access token to interact with the user's Google service data.

## OpenID Process

If they logout and log back into OpenID, we can find their token solely from the data they pass in (`openid_identifier`).  This is unlike Oauth, where we have to run through the whole process again because we don't know anything about them.