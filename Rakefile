require 'rubygems'
require 'bundler/setup'

require 'dashboard'
require 'dm-migrations'

require 'rake'

namespace :db do
  desc "DESTRUCTIVE: auto_migrates the database"
  task :migrate do
    DataMapper.auto_migrate!
  end
end

namespace :page_speed do
	desc "Fetch page speed results for configured projects"
  task :fetch_results do
  	PageSpeed.fetch_results
  end
end

desc "Run all specs (alias to spec)"
task :test => :spec
task :default => :spec

begin
  require 'rspec/core/rake_task'

  desc "Run all specs"
  RSpec::Core::RakeTask.new('spec') do |t|
    t.pattern = 'spec/**/*.rb'
  end

rescue MissingSourceFile # you're not in dev mode
  task :spec do
    abort "RSpec is not available. In order to run specs, you must: (sudo) gem install rspec or bundle install"
  end
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  desc 'Cucumber rake task not available (Cucumber not installed)'
  task :features do
    abort 'Cucumber is not available. In order to run specs, you must: (sudo) gem install cucumber or bundle install'
  end
end  

begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end

