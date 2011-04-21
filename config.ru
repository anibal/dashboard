require 'rubygems'
require 'bundler/setup'

require 'sinatra'

root_dir = File.dirname(__FILE__)

log = File.new("log/server.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

set :environment, ENV['RACK_ENV'].to_sym
set :root, root_dir
set :app_file, File.join(root_dir, 'dashboard.rb')

disable :run

require 'dashboard'
run Sinatra::Application
