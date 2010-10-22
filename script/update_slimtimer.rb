#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'rdoc/usage'
require 'logger'
require 'pp'

def bail_with_usage(opts)
  STDERR.puts opts
  exit
end

@options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"
  opts.on("-l", "--logfile FILE", "Log to FILE (default STDOUT)") do |l|
    @options[:log] = l
  end
  opts.on("-e", "--environment SINATRA_ENV", "Sinatra environment (default development)") do |e|
    @options[:environment] = e
  end
  opts.on_tail("-h", "--help", "Show this message") do
    bail_with_usage(opts)
  end
  args = opts.parse!(ARGV) rescue begin
    STDERR.puts "#{$!}\n"
    bail_with_usage(opts)
  end
end

require 'sinatra'

set :environment, @options[:environment] || ENV['SINATRA_ENV'] || 'development'
disable :run

def log
  @log ||= begin
             log = Logger.new((@options[:log] || STDOUT), 'daily')
             log.level = Logger::INFO
             log
           end
end

require File.join(File.dirname(__FILE__), '../dashboard')
require File.join(File.dirname(__FILE__), '../lib/slimtimer_api')

FULL_DATE_TIME = "%F %T"
ONE_HOUR = 1 * 60 * 60
ONE_DAY = 24 * ONE_HOUR
TWO_WEEKS = 2 * 7 * ONE_DAY

MAX_TIMEOUTS = 5

LAST_RUN_FILE = File.join(File.dirname(__FILE__), "../log/last_run")

# Runs a given block, handling timeouts
# It will retry the block up to _max_timeouts_ times.
# If max_timeouts is exceeded, it'll spit out the given _task_ to stderr,
# and exit the script with an error code.
def handle_timeouts(max_timeouts, task)
  timeouts = 0
  begin
    yield
  rescue Timeout::Error
    timeouts += 1
    if timeouts > MAX_TIMEOUTS
      log.fatal "Exceeded #{MAX_TIMEOUTS} timeouts on slimtimer during:\n  #{task}"
      raise "SlimTimer timed out #{MAX_TIMEOUTS} times, so we gave up."
    else
      log.debug "SlimTimer timed out (times: #{timeouts})"
      retry
    end
  end
end

def run_now?
  run_now = last_run.nil? ||
    ( Time.now > last_run + 24 * ONE_HOUR ) ||
    (( Time.now > last_run + 18 * ONE_HOUR ) && ( Time.now.hour <= 4 ))
  if !run_now
    log.info "Called, but decided not to do anything"
  end
  run_now
end

def last_run
  if File.exist?(LAST_RUN_FILE)
    File.mtime(LAST_RUN_FILE)
  else
    log.debug "#{LAST_RUN_FILE} didn't exist"
    nil
  end
end

def ran!
  FileUtils.touch(LAST_RUN_FILE)
  log.debug "Completed run and touched #{LAST_RUN_FILE}"
  log.debug "---"
end

exit unless run_now?

begin
  SLIMTIMER_USERS.each do |email, password|
    log.info "Loading slimtimer data for #{email}"
    st = SlimtimerApi.new(SLIMTIMER_APIKEY, email, password)
    log.info "  Slimtimer connected as user id #{st.user_id}"

    log.info "  Loading tasks"
    tasks = []
    handle_timeouts(MAX_TIMEOUTS, "loading tasks for #{email}") do
      tasks = st.tasks
    end
    log.info "    Got #{tasks.size} tasks; updating"
    SlimtimerTask.update(tasks)

    log.info "  Loading db user"
    u = SlimtimerUser.get(st.user_id)
    if u.nil?
      log.info "    Building new user"
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

      log.info "      Found person in one of their tasks:"
      log.info "      '#{person['name']}'"

      u.name = person['name']
      u.email = person['email']
      u.save
    end

    last_entry = u.time_entries.first(:order => [:end_time.desc])
    start_range = last_entry ? last_entry.end_time - TWO_WEEKS : Time.local(2010, 1, 1)
    end_range = [start_range + ONE_DAY, Time.now].min

    failed = 0
    until end_range >= Time.now
      handle_timeouts(MAX_TIMEOUTS, "retrieving time entries for #{email} on #{start_range}") do
        log.info "  Loading time entries from #{start_range} to #{end_range}"
        entries = st.time_entries(start_range.strftime(FULL_DATE_TIME),
                                end_range.strftime(FULL_DATE_TIME))
        log.info "    Got #{entries.size} entries"
        u.update_time_entries(entries)

        start_range = end_range
        end_range = start_range + 24 * 60 * 60
      end
    end
  end
rescue Interrupt
  log.info "Interrupted"
  log.info "---"
  exit 1
rescue
  raise if (Time.now > last_run + 40 * ONE_HOUR)
else
  ran!
end
