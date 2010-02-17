require 'spec/rake/spectask'

task :default => :spec

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color)
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "decent_exposure"
    gemspec.summary = "A helper for creating declarative interfaces in controllers"
    gemspec.description = %Q{
      DecentExposure helps you program to an interface, rather than an implementation
      in your Rails controllers.  The fact of the matter is that sharing state
      via instance variables in controllers promotes close coupling with views.
      DecentExposure gives you a declarative manner of exposing an interface to the
      state that controllers contain and thereby decreasing coupling and
      improving your testability and overall design.
    }
    gemspec.email = "scaudill@gmail.com"
    gemspec.homepage = "http://github.com/voxdolo/decent_exposure"
    gemspec.authors = ["Stephen Caudill", "Jon Larkowski"]
    gemspec.add_development_dependency "rspec", ">= 1.2.9"
    gemspec.add_development_dependency "mocha", ">= 0.9.8"
    gemspec.files = FileList[*%w(lib/**/* VERSION COPYING README.md rails/init.rb)]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
