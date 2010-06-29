%w[date rubygems sinatra sinatra/content_for haml dm-core dm-aggregates open-uri hpricot json librmpd yahoo-weather httparty].each { |lib| require lib }
%w[ext/fixnum ext/array mpd_proxy pivotal_api].each { |lib| require "lib/#{lib}" }
require 'config'
%w[ci pivotal slimtimer nagios].each { |lib| require "lib/#{lib}" }
%w[slimtimer_task slimtimer_user time_entry time_report].each { |model| require "models/#{model}" }

# -----------------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------------
helpers do
  def round(value)
    (value * 10).round / 10.0
  end

  def encode_special_time(time)
    time.strftime("%Y-%m-%d-%H-%M-%S")
  end

  def time_report_link(project, start, finish)
    str = '/time_reports'
    str << "/#{project}"
    str << "?start=#{encode_special_time(start)}"
    str << "&end=#{encode_special_time(finish)}"
  end
end


# -----------------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------------
get "/" do
  @body_class = "dashboard"

  @weather = YahooWeather::Client.new.lookup_location("ASXX0075", "c")
  @weather_image = Hpricot(@weather.description).at("img").attributes["src"]

  @projects = PROJECTS
  @projects.each do |name, attributes|
    iteration_dates = Pivotal.status_for(attributes[:pivotal])
    Slimtimer.status_for attributes[:slimtimer], iteration_dates
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

put "/:project_id/iterations/:iteration_id" do |project_id, iteration_id|
  Iteration.update_iteration(project_id, iteration_id, params)
  ""
end

get "/reports" do
  @projects = PROJECTS
  @projects.each do |name, attributes|
    iteration_dates = Pivotal.status_for(attributes[:pivotal])
    attributes[:prev_iteration] = iteration_dates.last
    attributes[:curr_iteration] = [iteration_dates.last.last, Time.now] rescue nil
  end

  haml :reports
end

get "/time_reports/:project" do |project|
  s = Time.local(*params['start'].split('-')) rescue Time.now - 7 * 24 * 3600
  e = Time.local(*params['end'].split('-')) rescue Time.now
  @time_report = TimeReport.new(s..e, project)
  @enable_blueprint = true
  haml :time_report
end
