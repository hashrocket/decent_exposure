lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'decent_exposure/version'

Gem::Specification.new do |s|
  s.name        = 'decent_exposure'
  s.version     = DecentExposure::VERSION
  s.authors     = ["Stephen Caudill", "Jon Larkowski"]
  s.email       = 'scaudill@gmail.com'
  s.homepage    = 'http://github.com/voxdolo/decent_exposure'

  s.description = %q{
    DecentExposure helps you program to an interface, rather than an
    implementation in your Rails controllers.  The fact of the matter is that
    sharing state via instance variables in controllers promotes close coupling
    with views.  DecentExposure gives you a declarative manner of exposing an
    interface to the state that controllers contain and thereby decreasing
    coupling and improving your testability and overall design.
  }

  s.summary = 'A helper for creating declarative interfaces in controllers'

  s.required_rubygems_version = '>= 1.3.6'

  s.files = Dir.glob("lib/**/*.rb") + %w(README.md)

  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2.7'
  s.add_development_dependency 'rspec-rails', '~> 2.7'
  s.add_development_dependency 'actionpack', '~> 3.1'
  s.add_development_dependency 'activesupport', '~> 3.1'
end
