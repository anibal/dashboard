class CI
  include HTTParty

  class << self
    def status_for(name, status)
      doc = get("#{CI_URL}?depth=1")
      jobs = doc["jobs"]

      unless project = jobs.find { |p| p["name"] == name }
        status[:status] = "no_ci"
      else
        status[:status] = color_map(project["color"])
        status[:health] = health(project["healthReport"], "Build")
        status[:rcov]   = health(project["healthReport"], "Rcov")
      end
    end

  private

    def color_map(ci_color)
      return case
        when %w[green blue].include?(ci_color)
          "green"
        when ci_color.include?("anime")
          "yellow"
        else
          "red"
        end
    end

    def health(report, id)
      return unless report = report.find { |r| r["description"] =~ %r{^#{id}} }
      report["iconUrl"]
    end
  end
end
