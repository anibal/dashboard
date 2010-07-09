class Pivotal
  include HTTParty
  headers({ "X-TrackerToken" => PIVOTAL_TOKEN })

  CACHE_EXPIRY = 60 * 15 # 15 minutes

  class << self
    def get(url)
      @cache ||= {}
      if @cache[url] && ((@cache[url].first + CACHE_EXPIRY) < Time.now)
        @cache[url] = nil
      end
      (@cache[url] ||= [Time.now, super]).last
    end

    def status_for(status)  # by ref! - that var will change!
      if status[:id]
        doc = get("#{PIVOTAL_URL}/projects/#{status[:id]}")
        status[:velocity] = doc["project"]["current_velocity"]

        status[:current] = current(status[:id])
        stats, dates = done(status[:id])
        status.merge!(stats)

        dates
      else
        status.merge!(
          :velocity => "-",
          :current  => "-",
          :points   => 1,
          :average  => "-"
        )
        []
      end
    end

    def current(id)
      doc = get("#{PIVOTAL_URL}/projects/#{id}/iterations/current")
      points_total(doc["iterations"].first["stories"].select {|s| s["current_state"] == "accepted" }.collect {|s| s["estimate"] })
    rescue NoMethodError
      status[:current] = 0
    end

    def done(id)
      doc = get("#{PIVOTAL_URL}/projects/#{id}/iterations/done?offset=-4")
      points = points_total(doc["iterations"].collect {|i| i["stories"] }.flatten.collect {|s| s["estimate"] })

      [{
        :points  => [points, 1].max,
        :average => (points / 4.0).round
      }, doc["iterations"].collect { |i| [i["start"], i["finish"]] }]
    rescue NoMethodError
      [{
        :points => 1,
        :average => 0
      }, nil]
    end

    def points_total(estimates)
      estimates.compact.inject { |sum, estimate| sum + estimate.to_i } || 0
    end

    def story(project_id, id)
      get("#{PIVOTAL_URL}/projects/#{project_id}/stories/#{id}")["story"]
    end
  end
end
