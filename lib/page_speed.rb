class PageSpeed
	include HTTParty

  class << self
		def results_file
			File.expand_path(File.join(File.dirname(__FILE__), "..", "tmp", "page_speed_scores.json"))
    end
    
		def fetch_results
      scores = {}
			projects = Project.all.select { |p| !p.attributes[:chartbeat_url].blank? }

      projects.each do |project|
        url = project.attributes[:chartbeat_url]
      	doc = get("#{GOOGLE_PAGE_SPEED_URL}?url=http://#{url}&key=#{GOOGLE_SIMPLE_APIKEY}")

        scores[project.id] = doc["score"]
      end

			File.open(results_file, "w+") do |f|
				f.puts scores.to_json
			end
    end

    def load_results
			@results ||= JSON.parse(File.read(results_file)).to_hash
    end
  end
end