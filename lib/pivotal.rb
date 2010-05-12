class Pivotal
  include HTTParty
  headers({ "X-TrackerToken" => PIVOTAL_TOKEN })

  class << self
    def status_for(status)  # by ref! - that var will change!
      if status[:id]
        doc = get("#{PIVOTAL_URL}/projects/#{status[:id]}")
        status[:velocity] = doc["project"]["current_velocity"]

        # current iteration
        begin
          doc = get("#{PIVOTAL_URL}/projects/#{status[:id]}/iterations/current")
          status[:current] = points_total(doc["iterations"].first["stories"].select {|s| s["current_state"] == "accepted" }.collect {|s| s["estimate"] })
        rescue NoMethodError
          status[:current] = 0
        end

        # last 4 iterations
        begin
          doc = get("#{PIVOTAL_URL}/projects/#{status[:id]}/iterations/done?offset=-4")
          points = points_total(doc["iterations"].collect {|i| i["stories"] }.flatten.collect {|s| s["estimate"] })
          status.merge!(
            :points  => [points, 1].max,
            :average => (points / 4.0).round
          )

          doc["iterations"].collect { |i| [i["start"], i["finish"]] }
        rescue NoMethodError
          status.merge!(
            :points => 1,
            :average => 0
          )
          nil
        end
      else
        status.merge!(
          :velocity => "-",
          :current  => "-",
          :points   => 1,
          :average  => "-"
        )
        nil
      end
    end

    def points_total(estimates)
      estimates.compact.inject { |sum, estimate| sum + estimate.to_i } || 0
    end

    def sprints(projects)
      res = {}

      projects.each do |id, attributes|
        pivotal_id = attributes[:pivotal][:id]
        next unless pivotal_id

        doc = get("#{PIVOTAL_URL}/projects/#{pivotal_id}/iterations/done")
        res.merge!(attributes[:name] => {
          :id => pivotal_id,
          :iterations => doc["iterations"].collect { |iteration|
            {
              :number => iteration["number"],
              :start => Date.parse(iteration["start"]),
              :finish => Date.parse(iteration["finish"])
            }
          }.reverse
        })
      end

      res
    end
  end
end
