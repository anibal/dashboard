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
