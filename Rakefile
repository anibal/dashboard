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

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = 'spec/**/*.rb'
end

desc "Run all specs (alias to spec)"
task :test => :spec
task :default => :spec
