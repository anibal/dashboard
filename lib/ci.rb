class CI
  class << self
    def status_for(name, status)
      doc = File.open(CI_STATUS_FILE) { |f| Hpricot::XML(f) }
      unless element = doc.at("//Project[@name = '#{name}']")
        status.merge!(
          :status   => "no_ci",
          :activity => "active"
        )
      else
        last_commit_time = Time.parse(element.attributes["lastBuildTime"])
        status.merge!(
          :status   => (element.attributes["activity"] == "Building" ? "building" : element.attributes["lastBuildStatus"].downcase),
          :label    => element.attributes["lastBuildLabel"],
          :message  => extract_message(element.attributes["lastCommitMessage"]),
          :author   => element.attributes["lastBuildAuthor"].split(" ")[0],
          :time     => time_ago_in_words(last_commit_time) + " ago",
          :activity => (distance_in_minutes(last_commit_time, utc_now) > 10080 ? "inactive" : "active")
        )
      end
    end

    def extract_message(message)
      message =~ /^Revision/ ? message.split("\n")[2] : message.strip
    end

    def distance_in_minutes(from, to)
      from = from.to_time if from.respond_to?(:to_time)
      to = to.to_time     if to.respond_to?(:to_time)
      (((to - from).abs) / 60.0).round
    end

    def distance_of_time_in_words(from_time, to_time = 0)
      distance = distance_in_minutes(from_time, to_time)
      case distance
        when 0               then "less than a minute"
        when 1               then "1 minute"
        when 2..44           then "#{distance} minutes"
        when 45..89          then "1 hour"
        when 90..1439        then "#{(distance.to_f / 60.0).round} hours"
        when 1440..2529      then "1 day"
        when 2530..43199     then "#{(distance.to_f / 1440.0).round} days"
        when 43200..86399    then "1 month"
        else                      "long"
      end
    end

    def time_ago_in_words(from_time)
      distance_of_time_in_words from_time, utc_now
    end

    def utc_now; Time.now.utc + (10 * 3600) end
  end
end
