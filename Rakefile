require 'rubygems'
require 'bundler/setup'

require 'dashboard'
require 'dm-migrations'

require 'rake'
require 'rspec/core/rake_task'

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

begin
	require 'rspec/core/rake_task'

  desc "Run all specs"
  RSpec::Core::RakeTask.new('spec') do |t|
    t.pattern = 'spec/**/*.rb'
  end

  desc "Run all specs (alias to spec)"
  task :test => :spec
  task :default => :spec
rescue MissingSourceFile # you're not in dev mode
end

