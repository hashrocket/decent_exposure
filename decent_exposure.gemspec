lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "version"

Gem::Specification.new do |spec|
  spec.name = "decent_exposure"
  spec.version = DecentExposure::VERSION
  spec.authors = ["Pavel Pravosud", "Stephen Caudill"]
  spec.email = ["info@hashrocket.com"]
  spec.summary = "Create declarative interfaces in Ruby on Rails controllers & views"
  spec.description = '
    DecentExposure helps you program to an interface, rather than an
    implementation in your Rails controllers.  The fact of the matter is that
    sharing state via instance variables in controllers promotes close coupling
    with views.  DecentExposure gives you a declarative manner of exposing an
    interface to the state that controllers contain and thereby decreasing
    coupling and improving your testability and overall design.
  '
  spec.homepage = "https://github.com/hashrocket/decent_exposure"
  spec.license = "MIT"
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|doc)/}) }
  end
  spec.require_path = "lib"

  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency "activesupport", ">= 4.0"
  spec.add_development_dependency "railties", ">= 4.0"
  spec.add_development_dependency "actionmailer", ">= 4.0"
  spec.add_development_dependency "rspec-rails", "~> 3.0"
  spec.add_development_dependency "standard"
end
