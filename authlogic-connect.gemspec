# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{authlogic-connect}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lance Pollard"]
  s.date = %q{2010-08-16}
  s.description = %q{Ruby Oauth and OpenID library that abstracts away all the complexities of connecting to multiple accounts.}
  s.email = ["lancejpollard@gmail.com"]
  s.files = ["README.markdown", "Rakefile", "init.rb", "MIT-LICENSE", "VERSION", "lib/authlogic-connect.rb", "lib/authlogic_connect", "lib/authlogic_connect/mixins", "lib/authlogic_connect/mixins/session.rb", "lib/authlogic_connect/mixins/user.rb", "lib/authlogic_connect/mixins.rb", "lib/authlogic_connect/oauth", "lib/authlogic_connect/oauth/session.rb", "lib/authlogic_connect/oauth/user.rb", "lib/authlogic_connect/oauth.rb", "lib/authlogic_connect/openid", "lib/authlogic_connect/openid/session.rb", "lib/authlogic_connect/openid/tokens", "lib/authlogic_connect/openid/tokens/openid_token.rb", "lib/authlogic_connect/openid/user.rb", "lib/authlogic_connect/openid.rb", "rails/init.rb", "test/config", "test/config/tokens.yml", "test/libs", "test/libs/database.rb", "test/libs/user.rb", "test/libs/user_session.rb", "test/test_helper.rb", "test/test_oauth.rb", "test/test_openid.rb", "test/test_user.rb"]
  s.homepage = %q{http://github.com/viatropos/authlogic-connect}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{authlogic-connect}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Oauth and OpenID made dead simple}

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
      s.add_runtime_dependency(%q<passport>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.1.2"])
      s.add_dependency(%q<activerecord>, [">= 2.1.2"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<ruby-openid>, [">= 0"])
      s.add_dependency(%q<rack-openid>, [">= 0.2.1"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<oauth2>, [">= 0"])
      s.add_dependency(%q<authlogic>, [">= 0"])
      s.add_dependency(%q<passport>, [">= 0"])
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
    s.add_dependency(%q<passport>, [">= 0"])
  end
end
