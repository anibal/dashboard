%w[rubygems sinatra haml open-uri hpricot json librmpd yahoo-weather].each { |lib| require lib }
require 'lib/mpd_proxy'
require 'lib/pivotal'

require 'lib/config'

# -----------------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------------
helpers do
  def distance_of_time_in_words(from_time, to_time = 0)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round

    case distance_in_minutes
      when 0               then "< 1 minute"
      when 1               then "1 minute"
      when 2..44           then "#{distance_in_minutes} minutes"
      when 45..89          then "1 hour"
      when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round} hours"
      when 1440..2529      then "1 day"
      when 2530..43199     then "#{(distance_in_minutes.to_f / 1440.0).round} days"
      when 43200..86399    then "1 month"
      else                      "long"
    end
  end

  def time_ago_in_words(from_time)
    distance_of_time_in_words(from_time, Time.now.utc + (11 * 3600))
  end

  def to_time(seconds)
    time = []
    time << "%02d" % (seconds / 3600) if seconds >= 3600
    time << "%02d" % ((seconds % 3600) / 60)
    time << "%02d" % (seconds % 60)
    "-" + time.join(":")
  end
end

# -----------------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------------
get "/" do
  @weather = YahooWeather::Client.new.lookup_location("ASXX0075", "c")
  haml :index
end

get "/project_status" do
  doc = open(CI_URL) { |f| Hpricot::XML(f) }

  status = PROJECTS
  (doc / :Project).each do |project|
    name = project.attributes["name"]
    build_status = (project.attributes["activity"] == "Building" ? "building" : project.attributes["lastBuildStatus"].downcase)

    status[name][:ci][:status] = build_status
    status[name][:ci][:label] = project.attributes["lastBuildLabel"]
    status[name][:ci][:author] = project.attributes["lastBuildAuthor"].split(" ")[0]
    status[name][:ci][:time] = time_ago_in_words(Time.parse(project.attributes["lastBuildTime"])) + " ago"

    Pivotal.get_status_for name, status[name][:pivotal]
  end

  status.to_json
end

get "/nagios_status" do
  { :system_count => 0, :problem_count => 0, :problems => [] }.to_json
end

get "/mpd_song" do
  "#{MpdProxy.current_song} (#{to_time(MpdProxy.time)})"
end
