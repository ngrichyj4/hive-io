lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hive/version'

Gem::Specification.new do |s|
  s.name        = 'hive-io'
  s.version     = Hive::VERSION
  s.date        = '2018-02-23'
  s.summary     = "A distributed executor service in ruby."
  s.description = "A library to execute multiple atomic tasks concurrently across multiple machines."
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ "Richard Aberefa" ]
  s.email       = 'ngrichyj4@gmail.com'
  s.license     = "MIT"
  s.files       = Dir['Gemfile', 'LICENSE.md', 'README.md', 'lib/**/*', 'dependencies.rb']
  s.homepage    = 'https://github.com/ngrichyj4/hive-io'
  s.add_dependency 'json', '~> 1.8.3', '>= 1.8.3'
  s.add_dependency 'celluloid', '~> 0.17.3'
  s.add_dependency 'colorize', '~> 0.8.1', '>= 0.8.1'
  s.add_dependency 'awesome_print', '~> 1.8.0', '>= 1.8.0'
  s.add_dependency 'eventmachine', '~> 1.2.5', '>= 1.2.5'
end