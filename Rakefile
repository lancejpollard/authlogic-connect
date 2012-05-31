require 'rake'
require "rdoc/task"
require 'rubygems/package_task'

# http://docs.rubygems.org/read/chapter/20
spec = Gem::Specification.new do |s|
  s.name              = "authlogic-connect"
  s.author            = "Lance Pollard"
  s.version           = "0.0.6.1"
  s.summary           = "Authlogic Connect: Oauth and OpenID made dead simple"
  s.homepage          = "http://github.com/viatropos/authlogic-connect"
  s.email             = "lancejpollard@gmail.com"
  s.description       = "Oauth and OpenID made dead simple"
  s.has_rdoc          = true
  s.rubyforge_project = "authlogic-connect"
  s.platform          = Gem::Platform::RUBY
  s.files             = %w(README.markdown Rakefile init.rb MIT-LICENSE) + Dir["{lib,rails,test}/**/*"] - Dir["test/tmp"]
  s.require_path      = "lib"
  s.add_dependency("activesupport", ">= 2.1.2")
  s.add_dependency("activerecord", ">= 2.1.2")
  s.add_dependency("json")
  s.add_dependency("ruby-openid")
  s.add_dependency("rack-openid", ">=0.2.1")
  s.add_dependency("oauth")
  s.add_dependency("oauth2")
  s.add_dependency("authlogic")
end

desc "Create .gemspec file (useful for github)"
task :gemspec do
  File.open("pkg/#{spec.name}.gemspec", "w") do |f|
    f.puts spec.to_ruby
  end
end

desc "Build the gem into the current directory"
task :gem => :gemspec do
  `gem build pkg/#{spec.name}.gemspec`
end

desc "Publish gem to rubygems"
task :publish => [:package] do
  %x[gem push pkg/#{spec.name}-#{spec.version}.gem]
end

desc "Print a list of the files to be put into the gem"
task :manifest do
  File.open("Manifest", "w") do |f|
    spec.files.each do |file|
      f.puts file
    end
  end
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec    = spec
  pkg.package_dir = "pkg"
end

desc "Install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/#{spec.name}-#{spec.version} --no-ri --no-rdoc}
end

desc "Generate the rdoc"
Rake::RDocTask.new do |rdoc|
  files = ["README.markdown", "lib/**/*.rb"]
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.markdown"
  rdoc.title = spec.summary
end

task :yank do
  `gem yank #{spec.name} -v #{spec.version}`
end

desc 'run unit tests'
task :test do
  Dir["test/**/*"].each do |file|
    next unless File.extname(file) == ".rb"
    next unless File.basename(file) =~ /test_/
    next if File.basename(file) =~ /test_helper/
    system "ruby #{file}"
  end
end
