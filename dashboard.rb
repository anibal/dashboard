%w[rubygems sinatra haml librmpd].each { |lib| require lib }
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
get "/mpd_song" do
  "#{MpdProxy.current_song} (#{to_time(MpdProxy.time)})"
end
