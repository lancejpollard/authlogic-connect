# AuthlogicConnect

bq. Instant Oauth and OpenID support for your Rails and Sinatra Apps

AuthlogicConnect is an extension of the Authlogic library that adds complete Oauth and OpenID support to your application.  It provides a single interface to Oauth 1.0 and Oauth 2.0.

It currently allows you to login with Github, Facebook, Twitter, Google, LinkedIn, MySpace, Vimeo, and Yahoo Oauth providers, and all the OpenID providers.  Feel free to add support for more as you need them.

Here's a **[live example](http://authlogic-connect.heroku.com)** on Heroku ([with source](http://github.com/viatropos/authlogic-connect-example)).

### Lists of known providers:

- [Oauth Providers](http://wiki.oauth.net/ServiceProviders)
- [OpenID Providers](http://en.wikipedia.org/wiki/List_of_OpenID_providers)
- [More OpenID](http://openid.net/get-an-openid/)

## Install

### 1. Install AuthlogicConnect

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
    
### 3.  Add the OpenIdAuthentication.store

Do to [some strange problem](http://github.com/openid/ruby-openid/issues#issue/1) I have yet to really understand, Rails 2.3.5 doesn't like when `OpenIdAuthentication.store` is null, which means it uses the "in memory" store and for some reason fails.

So as a fix, if you are using Rails < 3, add these at the end of your `config/environment.rb` files:

In development mode:

    OpenIdAuthentication.store = :file
    
In production (on Heroku primarily)

    OpenIdAuthentication.store = :memcache

### 4. Add the Migrations

See the [Rails 2 Example](http://github.com/viatropos/authlogic-connect-example-rails2) and [Rails 3 Example](http://github.com/viatropos/authlogic-connect-example) projects to see what you need.  Will add a generator sometime.

Files needed are:

- models: User, UserSession
- controllers: UsersController, UserSessionsController, ApplicationController
- migrations: create\_users, create\_sessions, create\_tokens
- initializers: config/authlogic.example.yml, config/initializers/authlogic_connect_config.rb
- routes
    
### 5. Configure your keys

In `config/authlogic.yml`, write your keys and secrets for each service you would like to support.  You have to manually go to the websites and register with the service provider (list of those links coming soon, in token classes for now).

    connect:
      twitter:
        key: "my_key"
        secret: "my_secret"
        label: "Twitter"
      facebook:
        key: "my_key"
        secret: "my_secret"
        label: "Facebook"
      google:
        key: "my_key"
        secret: "my_secret"
        label: "Google"
      yahoo:
        key: "my_key"
        secret: "my_secret"
        label: "Yahoo"
      myspace:
        key: "my_key"
        secret: "my_secret"
      vimeo:
        key: "my_key"
        secret: "my_secret"
      linked_in:
        key: "my_key"
        secret: "my_secret"

These are then loaded via the initializer script in `config/initializers/authlogic_connect_config.rb`:

    AuthlogicConnect.config = YAML.load_file("config/authlogic.yml")

### 6. Make sure you save your objects properly

Because of the redirects involved in Oauth and OpenID, you MUST pass a block to the `save` method in your UsersController and UserSessionsController:

    @user_session.save do |result|
      if result
        flash[:notice] # "Login successful!"
        redirect_back_or_default account_url
      else
        render :action => :new
      end
    end

If you don't use the block, we will get a DoubleRender error.  We need the block to jump out of the rendering while redirecting.
  
### 7. Add Parameters to Forms in your Views

There are 3 things to include in your views.

First, you must specify whether this is for _registration_ or _login_.  This is stored in the `authentication_type` key with a value of `user` for registration and `session` for login:

    %input{:type => :hidden, :name => :authentication_type, :value => :user}
    
Second, if you are using Oauth, you must include an input with name `oauth_provider` and value `twitter` or whatever other provider you might want (see example apps for dynamic example).

    %input{:type => :radio, :id => :twitter_oauth_provider, :name => :oauth_provider, :value => :twitter}
    
Finally, if you are using OpenID, you must include an input with name `openid_identifier`, which is a text field with the value the user types in for their address:

    %input.nice{:type => :text, :name => :openid_identifier}

Those are passed as parameters to Authlogic, and the complicated details are abstracted away.

## Overview of the User Experience

There are 3 ways you a user can login with AuthlogicConnect:

1. Clicking an Oauth Provider
2. Clicking an OpenID Provider and entering in their username
3. Manually typing in a full OpenID address

Oauth is very different from OpenID, but this aims to make them work the same.

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

## Helpful links

*	**Authlogic:** [http://github.com/binarylogic/authlogic](http://github.com/binarylogic/authlogic)
*	**AuthlogicConnect Example Project:** [http://github.com/viatropos/authlogic-connect-example](http://github.com/viatropos/authlogic-connect-example)
*	**Live example with Twitter and Facebook using Rails 3:** [http://authlogic-connect.heroku.com](http://authlogic-connect.heroku.com)
* **Rails 2.3.5 Example:** [http://github.com/viatropos/authlogic-connect-example-rails2](http://github.com/viatropos/authlogic-connect-example-rails2)
* **Rubygems Repository:** [http://rubygems.org/gems/authlogic-connect](http://rubygems.org/gems/authlogic-connect)

## Rest...

Thanks for the people that are already extending the project, all the input making things move much faster.

Feel free to add to the wiki if you figure things out or make new distinctions.

## Flow

- Try to create a session
- Session logs into provider
- On success, if no user, redirect to User#create

#### Notes

- Build mechanize tool to automatically create applications with service providers.