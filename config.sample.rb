# -----------------------------------------------------------------------------------
# Development environment
# -----------------------------------------------------------------------------------
configure :development do
  MpdProxy.setup "mpd", 6600, true

  DataMapper.setup(:default, "mysql://localhost/dashboard_dev")

  CI_STATUS_FILE = "tmp/ci_status_last.xml"
  PROJECTS = {
    "project1" => {
      :name => "Project 1",
      :ci => { },
      :pivotal => {
        :id => nil
      },
      :slimtimer  => {
        :id => "tri",
        :main_task => "t:tri type"
      }
    }
  }

  NAGIOS_URL = "http://nagios.trike.com.au/nagios/cgi-bin/status.cgi?host=all&servicestatustypes=28&hoststatustypes=15"

  PIVOTAL_URL = "http://www.pivotaltracker.com/services/v3"
  PIVOTAL_TOKEN = "token"

  SLIMTIMER_APIKEY = "key"
  SLIMTIMER_USERS = {
    "email@example.com" => "password"
  }
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

  CI_STATUS_FILE = "tmp/ci_status_last.xml"
  PROJECTS = {
    "project1" => {
      :name => "Project 1",
      :ci => { },
      :pivotal => {
        :id => nil
      },
      :slimtimer  => {
        :id => "tri",
        :main_task => "t:tri type"
      }
    }
  }

  NAGIOS_URL = "http://nagios.trike.com.au/nagios/cgi-bin/status.cgi?host=all&servicestatustypes=28&hoststatustypes=15"

  PIVOTAL_URL = "http://www.pivotaltracker.com/services/v3"
  PIVOTAL_TOKEN = "token"

  SLIMTIMER_APIKEY = "key"
  SLIMTIMER_USERS = {
    "email@example.com" => "password"
  }
end
