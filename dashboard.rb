%w[rubygems sinatra haml open-uri hpricot json librmpd].each { |lib| require lib }
require 'lib/mpd_proxy'

require 'lib/config'

# -----------------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------------
helpers do
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
  haml :index
end
get "/ci_status" do
  doc = open(CI_URL) { |f| Hpricot::XML(f) }

  status = PROJECTS
  (doc / :Project).each do |project|
    name = project.attributes["name"]
    build_status = (project.attributes["activity"] == "Building" ? "building" : project.attributes["lastBuildStatus"].downcase)

    status[name][:status] = build_status
    status[name][:label] = project.attributes["lastBuildLabel"]
    status[name][:author] = "(#{project.attributes["lastBuildAuthor"].split(" ")[0]})"
  end

  status.to_json
end
get "/mpd_song" do
  "#{MpdProxy.current_song} (#{to_time(MpdProxy.time)})"
end
