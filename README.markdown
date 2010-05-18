# Authlogic Connect

Authlogic Connect is an extension of the Authlogic library to add extensive Oauth and OpenID support. With Authlogic Connect, it's very easy to allow users to login through any of the 30+ authentication providers out there.  You shouldn't be reinventing the wheel anyways.

There are 3 ways you can allow your users to login with Authlogic Connect:

1. Clicking an Oauth Provider
2. Clicking an OpenID Provider and entering in their username
3. Manually typing in a full OpenID address

All of that is easier than creating a new account and password.

## Helpful links

*	<b>Authlogic:</b> [http://github.com/binarylogic/authlogic](http://github.com/binarylogic/authlogic)
*	<b>Authlogic Connect Example Project:</b> [http://github.com/viatropos/authlogic-connect-example](http://github.com/viatropos/authlogic-connect-example)
*	<b>Live example with Twitter and Facebook using Rails 3:</b> [http://authlogic-connect.heroku.com](http://authlogic-connect.heroku.com)
* <b>Rails 2.3.5 Example:</b> [http://github.com/viatropos/authlogic-connect-example-rails2](http://github.com/viatropos/authlogic-connect-example-rails2)
* **Rubygems Repository:** [http://rubygems.org/gems/authlogic-connect](http://rubygems.org/search?query=authlogic-connect)

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
      :services => {
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

### 6. Create Custom Tokens (if they don't already exist)

Here's an example of the FacebookToken for Oauth

    class FacebookToken < OauthToken

      version 2.0 # oauth 2.0

      settings "https://graph.facebook.com",
        :authorize_url => "https://graph.facebook.com/oauth/authorize",
        :scope         => "email, offline_access"

    end
    
If there is an Oauth/OpenID service you need, let me know, or fork/add/push and I will integrate it into the project and add you to the list.

Currently Implemented (some fully, some partially):

- [Oauth Tokens](http://github.com/viatropos/authlogic-connect/tree/master/lib/authlogic_connect/oauth/tokens/)
  
### 7. Add login and register buttons to your views

    <%# oauth_register_button :value => "Register with Twitter" %>
    <%# oauth_login_button :value => "Login with Twitter" %>

Check out the example projects to see exactly what's required.  These aren't totally useful yet.  Their job is to just send the right parameters to authlogic-connect.

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

This has no tests!  I had to build this in a day and am not fluent with Shoulda, which I'd like to use.  It should have lots of tests to make sure all permutations of login and account association work perfectly.

Goal:

- Test Framework: [Shoulda](http://github.com/thoughtbot/shoulda)
- Autotest with Shoulda
- Testing style like [Paperclip Tests](http://github.com/thoughtbot/paperclip/tree/master/test/)
- Rails 2.3+ and Rails 3 Compatability

I have no idea how to get up and running with Autotest and Shoulda right now.  If you know, I'd love to get the answer on Stack Overflow:

[http://stackoverflow.com/questions/2823224/what-test-environment-setup-do-committers-use-in-the-ruby-community](http://stackoverflow.com/questions/2823224/what-test-environment-setup-do-committers-use-in-the-ruby-community)

## TODO

- Change `register_with_oauth` and related to `register_method` and `login_method`: oauth, openid, traditional
- Build view helpers

## Helpful References for Rails 3

- [Rails 3 Initialization Process](http://ryanbigg.com/guides/initialization.html)
- [Rails 3 Plugins - Part 1, Big Picture](http://www.themodestrubyist.com/2010/03/01/rails-3-plugins---part-1---the-big-picture/)
- [Rails 3 Plugins - Part 2, Writing an Engine](http://www.themodestrubyist.com/2010/03/05/rails-3-plugins---part-2---writing-an-engine/)
- [Rails 3 Plugins - Part 3, Initializers](http://www.themodestrubyist.com/2010/03/16/rails-3-plugins---part-3---rake-tasks-generators-initializers-oh-my/)
- [Using Gemspecs as Intended](http://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)