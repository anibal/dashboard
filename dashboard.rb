%w[date rubygems sinatra sinatra/content_for haml dm-core dm-aggregates open-uri hpricot json librmpd yahoo-weather].each { |lib| require lib }
%w[ext/fixnum mpd_proxy ci pivotal nagios].each { |lib| require "lib/#{lib}" }
require 'models/iteration'
require 'lib/config'

# -----------------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------------
helpers do
  def round(value)
    (value * 10).round / 10.0
  end
end


# -----------------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------------
get "/" do
  @weather = YahooWeather::Client.new.lookup_location("ASXX0075", "c")

  @projects = PROJECTS
  @projects.each do |name, attributes|
    iteration_ids = Pivotal.status_for(attributes[:pivotal])
    Iteration.status_for(attributes[:pivotal], iteration_ids)
  end

  haml :index
end

get "/project_status" do
  status = PROJECTS
  status.each { |name, attributes| CI.status_for(name, attributes[:ci]) }
  status.to_json
end

get "/nagios_status" do
  Nagios.status.to_json
end

get "/mpd_song" do
  "#{MpdProxy.current_song} (#{MpdProxy.time.to_time})"
end

get "/nagios" do
  @status = Nagios.status
  haml :nagios, :layout => false
end

get "/input" do
  @sprints = Pivotal.sprints(PROJECTS)
  haml :input
end

put "/:project_id/iterations/:iteration_id" do |project_id, iteration_id|
  Iteration.update_iteration(project_id, iteration_id, params)
  ""
end
