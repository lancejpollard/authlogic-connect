# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{authlogic-connect}
  s.version = "0.0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lance Pollard"]
  s.date = %q{2010-09-06}
  s.description = %q{Oauth and OpenID made dead simple}
  s.email = %q{lancejpollard@gmail.com}
  s.files = ["README.markdown", "Rakefile", "init.rb", "MIT-LICENSE", "lib/authlogic-connect.rb", "lib/authlogic_connect", "lib/authlogic_connect/access_token.rb", "lib/authlogic_connect/authlogic_connect.rb", "lib/authlogic_connect/callback_filter.rb", "lib/authlogic_connect/common", "lib/authlogic_connect/common/session.rb", "lib/authlogic_connect/common/state.rb", "lib/authlogic_connect/common/user.rb", "lib/authlogic_connect/common/variables.rb", "lib/authlogic_connect/common.rb", "lib/authlogic_connect/engine.rb", "lib/authlogic_connect/ext.rb", "lib/authlogic_connect/oauth", "lib/authlogic_connect/oauth/helper.rb", "lib/authlogic_connect/oauth/process.rb", "lib/authlogic_connect/oauth/session.rb", "lib/authlogic_connect/oauth/state.rb", "lib/authlogic_connect/oauth/tokens", "lib/authlogic_connect/oauth/tokens/aol_token.rb", "lib/authlogic_connect/oauth/tokens/facebook_token.rb", "lib/authlogic_connect/oauth/tokens/foursquare_token.rb", "lib/authlogic_connect/oauth/tokens/get_satisfaction_token.rb", "lib/authlogic_connect/oauth/tokens/github_token.rb", "lib/authlogic_connect/oauth/tokens/google_token.rb", "lib/authlogic_connect/oauth/tokens/linked_in_token.rb", "lib/authlogic_connect/oauth/tokens/meetup_token.rb", "lib/authlogic_connect/oauth/tokens/myspace_token.rb", "lib/authlogic_connect/oauth/tokens/netflix_token.rb", "lib/authlogic_connect/oauth/tokens/oauth_token.rb", "lib/authlogic_connect/oauth/tokens/ohloh_token.rb", "lib/authlogic_connect/oauth/tokens/opensocial_token.rb", "lib/authlogic_connect/oauth/tokens/twitter_token.rb", "lib/authlogic_connect/oauth/tokens/vimeo_token.rb", "lib/authlogic_connect/oauth/tokens/yahoo_token.rb", "lib/authlogic_connect/oauth/user.rb", "lib/authlogic_connect/oauth/variables.rb", "lib/authlogic_connect/oauth.rb", "lib/authlogic_connect/openid", "lib/authlogic_connect/openid/process.rb", "lib/authlogic_connect/openid/session.rb", "lib/authlogic_connect/openid/state.rb", "lib/authlogic_connect/openid/tokens", "lib/authlogic_connect/openid/tokens/aol_token.rb", "lib/authlogic_connect/openid/tokens/blogger_token.rb", "lib/authlogic_connect/openid/tokens/flickr_token.rb", "lib/authlogic_connect/openid/tokens/my_openid_token.rb", "lib/authlogic_connect/openid/tokens/openid_token.rb", "lib/authlogic_connect/openid/user.rb", "lib/authlogic_connect/openid/variables.rb", "lib/authlogic_connect/openid.rb", "lib/authlogic_connect/rack_state.rb", "lib/open_id_authentication.rb", "rails/init.rb", "test/controllers", "test/controllers/test_users_controller.rb", "test/libs", "test/libs/database.rb", "test/libs/user.rb", "test/libs/user_session.rb", "test/test_helper.rb", "test/test_oauth.rb", "test/test_openid.rb", "test/test_user.rb"]
  s.homepage = %q{http://github.com/viatropos/authlogic-connect}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{authlogic-connect}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Authlogic Connect: Oauth and OpenID made dead simple}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.1.2"])
      s.add_runtime_dependency(%q<activerecord>, [">= 2.1.2"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-openid>, [">= 0"])
      s.add_runtime_dependency(%q<rack-openid>, [">= 0.2.1"])
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<oauth2>, [">= 0"])
      s.add_runtime_dependency(%q<authlogic>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.1.2"])
      s.add_dependency(%q<activerecord>, [">= 2.1.2"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<ruby-openid>, [">= 0"])
      s.add_dependency(%q<rack-openid>, [">= 0.2.1"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<oauth2>, [">= 0"])
      s.add_dependency(%q<authlogic>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.1.2"])
    s.add_dependency(%q<activerecord>, [">= 2.1.2"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<ruby-openid>, [">= 0"])
    s.add_dependency(%q<rack-openid>, [">= 0.2.1"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<oauth2>, [">= 0"])
    s.add_dependency(%q<authlogic>, [">= 0"])
  end
end
