class Pivotal

  class << self
    def status_for(name, status)
      if status[:id]
        doc = open("#{PIVOTAL_URL}/projects/#{status[:id]}", { "X-TrackerToken" => PIVOTAL_TOKEN } ) { |f| Hpricot::XML(f) }

        status[:velocity] = doc.at("current_velocity").innerHTML
      else
        status[:velocity] = "N/A"
      end
    end
  end
end
