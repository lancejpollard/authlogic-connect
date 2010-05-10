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

## Supported Providers

Lists of all known providers here:

- [Oauth Providers](http://wiki.oauth.net/ServiceProviders)
- [OpenID Providers](http://en.wikipedia.org/wiki/List_of_OpenID_providers)

### Oauth

- Twitter
- Facebook
- Google

### OpenID

- MyOpenID

## Install and use

### 1. Install Authlogic and setup your application

    sudo gem install authlogic

### 2. Install OAuth and Authlogic Connect

    sudo gem install oauth
    sudo gem install authlogic-connect

Now add the gem dependencies in your config:

    config.gem "json"
    config.gem "authlogic"
    config.gem "oauth"
    config.gem "oauth2"
    config.gem "authlogic-connect", :lib => "authlogic_connect"

### 3. Add the Migrations

If you are starting from scratch (and you don't even have a User model yet), create the migrations using this command.

    script/generate authlogic_connect_migration

Otherwise, add this migration

    class AddAuthlogicConnectMigration < ActiveRecord::Migration
      def self.up
        add_column :users, :oauth_token, :string
        add_column :users, :oauth_secret, :string
        add_index :users, :oauth_token

        change_column :users, :login, :string, :default => nil, :null => true
        change_column :users, :crypted_password, :string, :default => nil, :null => true
        change_column :users, :password_salt, :string, :default => nil, :null => true
      end

      def self.down
        remove_column :users, :oauth_token
        remove_column :users, :oauth_secret

        [:login, :crypted_password, :password_salt].each do |field|
          User.all(:conditions => "#{field} is NULL").each { |user| user.update_attribute(field, "") if user.send(field).nil? }
          change_column :users, field, :string, :default => "", :null => false
        end
      end
    end
  
### 4. Make sure you save your objects properly

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

### 5. Create Custom Tokens (if they don't already exist)

Here's an example of the FacebookToken for Oauth

    class FacebookToken < OauthToken
    
    end
  
### 6. Add login and register buttons to your views

    <%# oauth_register_button :value => "Register with Twitter" %>
    <%# oauth_login_button :value => "Login with Twitter" %>

That's it! The rest is taken care of for you.

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

## Tests

This has no tests!  I had to build this in a weekend and am not fluent with Shoulda, which I'd like to use.  One of these days when I can breathe.