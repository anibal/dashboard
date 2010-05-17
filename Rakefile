require 'dashboard'

require 'rake'                                                                                               
require 'spec/rake/spectask'

namespace :db do
  desc "DESTRUCTIVE: auto_migrates the database"
  task :migrate do
    DataMapper.auto_migrate!
  end
end

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

desc "Run all specs (alias to spec)"
task :test => :spec
task :default => :spec
