# -----------------------------------------------------------------------------------
# Development environment
# -----------------------------------------------------------------------------------
configure :development do
  MpdProxy.setup "mpd", 6600

  CI_URL = "http://ci.trike.com.au/XmlStatusReport.aspx"
  PROJECTS = {
    "project1" => {
      :name => "Project 1",
      :identifier => "P1",
      :ci => { },
      :pivotal => {
        :id => nil
      }
    }
  }

  NAGIOS_URL = "http://nagios.trike.com.au/nagios/cgi-bin/status.cgi"

  PIVOTAL_URL = "http://www.pivotaltracker.com/services/v3"
  PIVOTAL_TOKEN = ""
end

# -----------------------------------------------------------------------------------
# Production environment
# -----------------------------------------------------------------------------------
configure :production do
  MpdProxy.setup "mpd", 6600, true

  CI_URL = "http://ci.trike.com.au/XmlStatusReport.aspx"
  PROJECTS = {
    "project1" => {
      :name => "Project 1",
      :identifier => "P1",
      :ci => { },
      :pivotal => {
        :id => nil
      }
    }
  }

  NAGIOS_URL = "http://nagios.trike.com.au/nagios/cgi-bin/status.cgi"

  PIVOTAL_URL = "http://www.pivotaltracker.com/services/v3"
  PIVOTAL_TOKEN = ""
end