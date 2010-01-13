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
    gemspec.name = "let-it-be"
    gemspec.summary = "an implementation of .let for controllers"
    gemspec.description = %Q{
      LetItBe helps you program to an interface, rather than an implementation
      in your Rails controllers.  The fact of the matter is that sharing state
      via instance variables in controllers promotes close coupling with views.
      LetItBe gives you a declarative manner of exposing an interface to the
      state that controllers contain and thereby decreasing coupling and
      improving your testability and overall design.
    }
    gemspec.email = "scaudill@gmail.com"
    gemspec.homepage = "http://github.com/voxdolo/let-it-be"
    gemspec.authors = ["Stephen Caudill", "Jon Larkowski"]
    gemspec.add_development_dependency "rspec", ">= 1.2.9"
    gemspec.files = FileList["{bin,lib}/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
