class CI
  class << self
    def status_for(name, status)
      doc = open(CI_URL) { |f| Hpricot::XML(f) }
      element = doc.search("//Project[@name = '#{name}']").first

      status.merge!(
        :status  => (element.attributes["activity"] == "Building" ? "building" : element.attributes["lastBuildStatus"].downcase),
        :label   => element.attributes["lastBuildLabel"],
        :message => extract_message(element.attributes["lastCommitMessage"]),
        :author  => element.attributes["lastBuildAuthor"].split(" ")[0],
        :time    => time_ago_in_words(Time.parse(element.attributes["lastBuildTime"])) + " ago"
      )
    end

    def extract_message(message)
      "test"
    end

    def distance_of_time_in_words(from_time, to_time = 0)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      distance_in_minutes = (((to_time - from_time).abs)/60).round

      case distance_in_minutes
        when 0               then "< 1 minute"
        when 1               then "1 minute"
        when 2..44           then "#{distance_in_minutes} minutes"
        when 45..89          then "1 hour"
        when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round} hours"
        when 1440..2529      then "1 day"
        when 2530..43199     then "#{(distance_in_minutes.to_f / 1440.0).round} days"
        when 43200..86399    then "1 month"
        else                      "long"
      end
    end

    def time_ago_in_words(from_time)
      distance_of_time_in_words(from_time, Time.now.utc + (11 * 3600))
    end
  end
end
