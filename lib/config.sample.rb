# -----------------------------------------------------------------------------------
# Development environment
# -----------------------------------------------------------------------------------
configure :development do
  MpdProxy.setup "mpd", 6600

  CI_URL = "http://ci.trike.com.au/XmlStatusReport.aspx"
  PROJECTS = {
    "project1" => {
      :identifier => "P1",
      :status => ""
    }
  }
end

# -----------------------------------------------------------------------------------
# Production environment
# -----------------------------------------------------------------------------------
configure :production do
  MpdProxy.setup "mpd", 6600, true

  CI_URL = "http://ci.trike.com.au/XmlStatusReport.aspx"
  PROJECTS = {
    "project1" => {
      :identifier => "P1",
      :status => ""
    }
  }
end