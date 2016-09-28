require File.expand_path("../lib/decent_exposure/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name         = "decent_exposure"
  spec.version      = DecentExposure::VERSION
  spec.authors      = ["Pavel Pravosud", "Stephen Caudill"]
  spec.email        = ["info@hashrocket.com"]
  spec.summary      = "A helper for creating declarative interfaces in controllers"
  spec.description = %q{
    DecentExposure helps you program to an interface, rather than an
    implementation in your Rails controllers.  The fact of the matter is that
    sharing state via instance variables in controllers promotes close coupling
    with views.  DecentExposure gives you a declarative manner of exposing an
    interface to the state that controllers contain and thereby decreasing
    coupling and improving your testability and overall design.
  }
  spec.homepage     = "https://github.com/hashrocket/decent_exposure"
  spec.license      = "MIT"
  spec.files        = `git ls-files -z`.split("\x0")
  spec.test_files   = spec.files.grep(/\Aspec\//)
  spec.require_path = "lib"

  spec.required_ruby_version = "~> 2.0"

  spec.add_dependency "activesupport", ">= 4.0"
  spec.add_development_dependency "railties", ">= 4.0"
  spec.add_development_dependency "actionmailer"
  spec.add_development_dependency "rspec-rails", "~> 3.0"
end
