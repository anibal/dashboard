class Pivotal

  class << self
    def status_for(status)
      if status[:id]
        doc = open("#{PIVOTAL_URL}/projects/#{status[:id]}", { "X-TrackerToken" => PIVOTAL_TOKEN }) { |f| Hpricot::XML(f) }
        status[:velocity] = doc.at("current_velocity").innerHTML

        # current iteration
        doc = open("#{PIVOTAL_URL}/projects/#{status[:id]}/iterations/current", { "X-TrackerToken" => PIVOTAL_TOKEN }) { |f| Hpricot::XML(f) }
        status[:current] = points_total(doc.search("//story").select { |story| story.at("current_state").innerHTML == "accepted" }.map { |story| story.at("estimate") })

        # last 4 iterations
        doc = open("#{PIVOTAL_URL}/projects/#{status[:id]}/iterations/done?offset=-4", { "X-TrackerToken" => PIVOTAL_TOKEN }) { |f| Hpricot::XML(f) }
        points = points_total(doc.search("//estimate"))
        status.merge!(
          :points => [points, 1].max,
          :average => (points / 4.0).round
        )

        from = Date.parse(doc.search("//iteration:first").at("start").innerHTML)
        to = Date.parse(doc.search("//iteration:last").at("finish").innerHTML)
        [from, to]
      else
        status.merge!(
          :velocity => "-",
          :current  => "-",
          :points   => 1,
          :average  => "-"
        )
        [nil, nil]
      end
    end

    def points_total(estimates)
      estimates.compact.map { |e| e.innerHTML.to_i }.inject { |sum, estimate| sum + estimate } || 0
    end
  end
end
