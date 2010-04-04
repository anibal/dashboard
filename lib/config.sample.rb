# -----------------------------------------------------------------------------------
# Development environment
# -----------------------------------------------------------------------------------
configure :development do
  MpdProxy.setup "mpd", 6600

  DataMapper.setup(:default, "mysql://localhost/dashboard_dev")

  CI_URL = "http://ci.trike.com.au/XmlStatusReport.aspx"
  PROJECTS = {
    "project1" => {
      :name => "Project 1",
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

  DataMapper.setup(:default, {
    :adapter  => "mysql",
    :database => "dashboard_prod",
    :username => "dashoard_prod",
    :password => "",
    :host     => "mysql"
  })

  CI_URL = "http://ci.trike.com.au/XmlStatusReport.aspx"
  PROJECTS = {
    "project1" => {
      :name => "Project 1",
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