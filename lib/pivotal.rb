class Pivotal

  class << self
    def status_for(status)
      if status[:id]
        doc = open("#{PIVOTAL_URL}/projects/#{status[:id]}", { "X-TrackerToken" => PIVOTAL_TOKEN }) { |f| Hpricot::XML(f) }
        status[:velocity] = doc.at("current_velocity").innerHTML

        # current iteration
        begin
          doc = open("#{PIVOTAL_URL}/projects/#{status[:id]}/iterations/current", { "X-TrackerToken" => PIVOTAL_TOKEN }) { |f| Hpricot::XML(f) }
          status[:current] = points_total(doc.search("//story").select { |story| story.at("current_state").innerHTML == "accepted" }.map { |story| story.at("estimate") })
        rescue NoMethodError
          status[:current] = 0
        end

        # last 4 iterations
        begin
          doc = open("#{PIVOTAL_URL}/projects/#{status[:id]}/iterations/done?offset=-4", { "X-TrackerToken" => PIVOTAL_TOKEN }) { |f| Hpricot::XML(f) }
          points = points_total(doc.search("//estimate"))
          status.merge!(
            :points  => [points, 1].max,
            :average => (points / 4.0).round
          )
        rescue NoMethodError
          status.merge!(
            :points => 1,
            :average => 0
          )
        end
      else
        status.merge!(
          :velocity => "-",
          :current  => "-",
          :points   => 1,
          :average  => "-"
        )
      end
    end

    def points_total(estimates)
      estimates.compact.map { |e| e.innerHTML.to_i }.inject { |sum, estimate| sum + estimate } || 0
    end

    def sprints(projects)
      res = {}

      projects.each do |id, attributes|
        pivotal_id = attributes[:pivotal][:id]
        next unless pivotal_id

        doc = open("#{PIVOTAL_URL}/projects/#{pivotal_id}/iterations/done", { "X-TrackerToken" => PIVOTAL_TOKEN }) { |f| Hpricot::XML(f) }
        res.merge!(attributes[:name] => {
          :id => pivotal_id,
          :iterations => doc.search("//iteration").map { |iteration|
            {
              :number => iteration.at("number").innerHTML,
              :start => Date.parse(iteration.at("start").innerHTML),
              :finish => Date.parse(iteration.at("finish").innerHTML)
            }
          }.reverse
        })
      end

      res
    end
  end
end
