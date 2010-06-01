#!/usr/bin/env ruby

%w[rubygems sinatra].each {|l| require l }

set :environment, ENV['SINATRA_ENV'] || 'development'
disable :run

require File.join(File.dirname(__FILE__), '../dashboard')
require File.join(File.dirname(__FILE__), '../lib/slimtimer_api')
require 'pp'

FULL_DATE_TIME = "%F %T"

SLIMTIMER_USERS.each do |email, password|
  puts "Loading slimtimer data for #{email}"
  st = SlimtimerApi.new(SLIMTIMER_APIKEY, email, password)
  puts "  Slimtimer connected as user id #{st.user_id}"

  puts "  Loading tasks"
  tasks = st.tasks
  puts "    Got #{tasks.size} tasks; updating"
  SlimtimerTask.update(tasks)

  puts "  Loading db user"
  u = SlimtimerUser.get(st.user_id)
  if u.nil?
    puts "    Building new user"
    u = SlimtimerUser.new
    u.id = st.user_id
    task = tasks.first # FIXME Assumes that at least one task was returned
    person = %w[owners coworkers reporters].map { |k|
      a = if task[k].nil? || task[k]['person'].nil?
        []
      else
        if task[k]['person'].is_a? Hash
          [task[k]['person']]
        else
          task[k]['person']
        end
      end
      pp a
      a
    }.flatten.find { |person| person['user_id'] == u.id }

    puts "      Found person in one of their tasks:"
    puts "      '#{person['name']}'"

    u.name = person['name']
    u.email = person['email']
    u.save
  end

  last_entry = u.time_entries.first(:order => [:end_time.desc])
  start_range = last_entry ? last_entry.end_time : Time.local(2010, 1, 1)
  end_range = [start_range + 24 * 60 * 60, Time.now].min

  until end_range >= Time.now
    puts "  Loading time entries from #{start_range} to #{end_range}"

    entries = st.time_entries(start_range.strftime(FULL_DATE_TIME),
                              end_range.strftime(FULL_DATE_TIME))

    puts "    Got #{entries.size} entries"


    puts "    Updating time entries"
    u.update_time_entries(entries)

    start_range = end_range
    end_range = start_range + 24 * 60 * 60
  end
end
