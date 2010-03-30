%w[date rubygems sinatra haml open-uri hpricot json librmpd yahoo-weather].each { |lib| require lib }
%w[ext/fixnum mpd_proxy ci pivotal].each { |lib| require "lib/#{lib}" }
require 'lib/config'

# -----------------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------------
get "/" do
  @weather = YahooWeather::Client.new.lookup_location("ASXX0075", "c")

  @projects = PROJECTS
  @projects.each do |name, attributes|
    Pivotal.status_for(attributes[:pivotal])
  end

  haml :index
end

get "/project_status" do
  status = PROJECTS
  status.each { |name, attributes| CI.status_for(name, attributes[:ci]) }
  status.to_json
end

get "/nagios_status" do
  { :system_count => 0, :problem_count => 0, :problems => [] }.to_json
end

get "/mpd_song" do
  "#{MpdProxy.current_song} (#{MpdProxy.time.to_time})"
end

get "/input" do
  @sprints = Pivotal.sprints(PROJECTS)
  haml :input
end


