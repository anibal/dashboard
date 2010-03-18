class Pivotal

  class << self
    def status_for(name, status)
      if status[:id]
        doc = open("#{PIVOTAL_URL}/projects/#{status[:id]}", { "X-TrackerToken" => PIVOTAL_TOKEN } ) { |f| Hpricot::XML(f) }
        status[:velocity] = doc.at("current_velocity").innerHTML

        doc = open("#{PIVOTAL_URL}/projects/#{status[:id]}/iterations/current", { "X-TrackerToken" => PIVOTAL_TOKEN } ) { |f| Hpricot::XML(f) }
        status.merge!(
          :points => points_total(doc.search("//story").select { |story| story.at("current_state").innerHTML == "accepted" }.map { |story| story.at("estimate") }),
          :goal => points_total(doc.search("//estimate"))
        )
      else
        status.merge!(
          :velocity => "N/A",
          :points => 0,
          :goal => 0
        )
      end
    end

    def points_total(estimates)
      estimates.compact.map { |e| e.innerHTML.to_i }.inject { |sum, estimate| sum + estimate } || 0
    end
  end
end
