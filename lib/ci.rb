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
        status[:health] = health(project["healthReport"])
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

    def health(report)
      return unless report[0]
      report[0]["iconUrl"]
    end
  end
end
