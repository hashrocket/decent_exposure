$:.unshift 'lib'

require 'decent_exposure/version'

desc 'Build gem from gemspec'
task :build do
  system 'gem build decent_exposure.gemspec'
end

desc 'Install built gem'
task :install => :build do
  system "sudo gem install decent_exposure-#{DecentExposure::VERSION}.gem"
end

desc 'Automate tagging, pushing, and releasing gem'
task :release => :build do
  puts "Tagging #{DecentExposure::VERSION}..."
  system "git tag -a #{DecentExposure::VERSION} -m 'Tagging #{DecentExposure::VERSION}'"
  puts "Pushing to Github..."
  system "git push --tags"
  puts "Pushing to rubygems.org..."
  system "gem push mongoid-#{DecentExposure::VERSION}.gem"
end  

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec
