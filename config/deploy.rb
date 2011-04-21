trikelibs = Dir['config/cap-tasks/*.rb'].reject{ |file| file =~ /(radiant)/ }
trikelibs.each { |trikelib| load(trikelib)  }

stages_glob = File.join(File.dirname(__FILE__), "deploy", "*.rb")
stages = Dir[stages_glob].collect { |f| File.basename(f, ".rb") }.sort
set :stages, stages
set :default_stage, 'it'
require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :application, "dashboard"
set :repository,  "git://github.com/tricycle/dashboard.git"

set :scm, :git
set :repository_cache, 'cached-copy'
set :git_enable_submodules, 1
set :deploy_via, :remote_cache

role :web, "pepper.trike.com.au"                          # Your HTTP server, Apache/etc
role :app, "pepper.trike.com.au"                          # This may be the same as your `Web` server
role :db,  "pepper.trike.com.au", :primary => true # This is where Rails migrations will run

set :user, "www-data"
set :engine, "passenger"

after "deploy:update_code", "deploy:update_app_config"
after "deploy:symlink",     "assets:symlink_shared_dirs"

namespace :deploy do
  task :update_app_config do
    run "ln -sf #{shared_path}/config.rb #{release_path}/config.rb"
  end
end

#namespace :deploy do
#  task :restart do
#    run "touch #{current
#    sudo "/etc/init.d/apache2 restart"
#  end
#end

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
