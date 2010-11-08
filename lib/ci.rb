class CI
  include HTTParty

  class << self
    def status_for(name, status)
      doc = get("#{CI_URL}?depth=1")
      jobs = doc["jobs"]

      unless project = jobs.find { |p| p["name"] == name }
        status[:status] = "no_ci"
      else
        status[:status] = project["color"]
        status[:health] = health(project["healthReport"])
      end
    end

    def health(report)
      return unless report[0]
      report[0]["iconUrl"]
    end
  end
end
