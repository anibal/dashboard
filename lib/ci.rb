class CI
  include HTTParty

  class << self
    def status_for(name, status)
      doc = get(CI_URL)
      jobs = doc["jobs"]

      unless project = jobs.find { |p| p["name"] == name }
        status[:status] = "no_ci"
      else
        status[:status] = project["color"]
      end
    end
  end
end
