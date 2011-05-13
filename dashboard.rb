%w[ date rubygems sinatra sinatra/content_for haml dm-core dm-aggregates
    open-uri hpricot json librmpd yahoo-weather httparty active_support/all ].each { |lib| require lib }
%w[ ext/fixnum ext/array mpd_proxy ].each { |lib| require "lib/#{lib}" }
require 'config'
%w[ ci pivotal nagios stats pivotal_slimtimer_updater page_speed ].each { |lib| require "lib/#{lib}" }
%w[ project slimtimer_task slimtimer_user time_entry report time_report summary_report story shepherd
  ].each { |model| require "models/#{model}" }

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

  def report_link(start, finish, project_id = "summary")
    str = '/time_reports'
    str << "/#{project_id}"
    str << "?start=#{encode_special_time(start)}"
    str << "&end=#{encode_special_time(finish)}"
  end

  def max_activity_across_projects(projects)
    projects.map { |k, v| v[:activity] }.inject([]) { |all, values| all + values }.max
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
  @chartbeat_api_key = CHARTBEAT_APIKEY

  @weather = YahooWeather::Client.new.lookup_location("ASXX0075", "c")
  @weather_image = Hpricot(@weather.description).at("img").attributes["src"]
  @weather_condition = case @weather.condition.code.to_i
                       when 32: 'Cider Weather'
                       else
                         @weather.condition.text
                       end

  @projects = PROJECTS.reject { |name, attributes| attributes[:hidden] }
  @projects.each do |name, attributes|
    attributes[:activity] 				= Stats.status_for(name)
    attributes[:shepherd] 				= Project.find(name).shepherd
    attributes[:page_speed_score] = PageSpeed.load_results[name]
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
  @body_class = "reports"

  @projects = Project.all

  @ranges = [
    { :start => 2.weeks.ago.beginning_of_week, :finish => 2.weeks.ago.end_of_week, :name => '2 weeks ago' },
    { :start => 1.week.ago.beginning_of_week, :finish => 1.week.ago.end_of_week, :name => 'Last week' },
    { :start => Time.now.beginning_of_week, :finish => Time.now.end_of_week, :name => 'This week' },
  ]

  haml :reports
end

get "/time_reports/summary" do |project_id|
  s = Time.local(*params['start'].split('-'))
  e = Time.local(*params['end'].split('-'))

  @summary_report = SummaryReport.new(s..e)

  @enable_blueprint = true
  haml :summary_report
end

get "/time_reports/:project" do |project_id|
  s = Time.local(*params['start'].split('-'))
  e = Time.local(*params['end'].split('-'))

  @time_report = TimeReport.new(s..e, Project.find(project_id))

  @enable_blueprint = true
  haml :time_report
end

post "/update_story" do
  story = Story.first_or_create('id' => params['id'])
  story.attributes = { 'billed' => false }.merge(params['story'] || {})
  story.save

  status 200
end

get "/shepherds" do
  @projects = Project.all
  haml :shepherds
end

post "/shepherds/update" do
  params["shepherd"].each do |project, name|
    shepherd = Shepherd.first_or_create(:project => project)
    shepherd.name = name
    shepherd.save
  end

  redirect "/shepherds"
end

post "/projects/:project_id/pivotal_update" do |project_id|
  project = Project.find(project_id)
  updater = PivotalSlimtimerUpdater.new(project, request.body.read)
  updater.update if updater.valid?
end

