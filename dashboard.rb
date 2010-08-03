%w[date rubygems sinatra sinatra/content_for haml dm-core dm-aggregates open-uri hpricot json librmpd yahoo-weather httparty].each { |lib| require lib }
%w[ext/fixnum ext/array mpd_proxy].each { |lib| require "lib/#{lib}" }
require 'config'
%w[ci pivotal nagios stats].each { |lib| require "lib/#{lib}" }
%w[project slimtimer_task slimtimer_user time_entry time_report].each { |model| require "models/#{model}" }

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
    str << "/#{project.id}"
    str << "?start=#{encode_special_time(start)}"
    str << "&end=#{encode_special_time(finish)}"
  end

  def height_for(val, max)
    [(20 * (val.to_f / max)).to_i, 1].max
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
    Pivotal.status_for(attributes[:pivotal])
    attributes[:activity] = Stats.status_for(name)
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
  @projects = Project.all
  haml :reports
end

get "/time_reports/:project" do |project_id|
  s = Time.local(*params['start'].split('-')) rescue Time.now - 7 * 24 * 3600
  e = Time.local(*params['end'].split('-')) rescue Time.now
  @time_report = TimeReport.new(s..e, Project.find(project_id))
  @enable_blueprint = true
  haml :time_report
end
