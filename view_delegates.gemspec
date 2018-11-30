$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'view_delegates/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'view_delegates'
  s.version     = ViewDelegates::VERSION
  s.authors     = ['Miguel Aurelio Lamas Murias']
  s.email       = ['miguel.aurelio.murias28@gmail.com']
  s.summary     = 'Easy view delegates for ruby on rails'
  s.description = 'Easy view delegates for ruby on rails'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'rspec-rails', '~>3.7'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'simplecov'
end
