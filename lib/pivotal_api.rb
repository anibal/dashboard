require 'httparty'

class PivotalApi
  include HTTParty

  attr_accessor :project_id

  def initialize(apikey, project_id)
    #self.class.headers "X-TrackerToken" => apikey
    #self.class.base_uri "http://www.pivotaltracker.com/services/v3/projects/#{project_id}"
    @apikey = apikey
    self.project_id = project_id
  end

  def stories(filter = "")
    get("/stories", :query => {:filter => clean_filter(filter)})["stories"]
  end

  def story(id, filter = "")
    get("/stories/#{id}", :query => {:filter => clean_filter(filter)})["story"]
  end

  def iterations(group = 'done')
    get("/iterations/#{group}")["iterations"]
  end

  def clean_filter(filter)
    if filter.is_a?(Hash)
      filter.collect {|k,v| "#{k}:#{v}"}.join(" ")
    elsif filter.respond_to?(:to_s) && filter.match(/^\w+:[^ ]+( \w+:[^ ]+)*$/)
      filter.to_s
    else
      abort "I'm expecting a filter like 'id:1,2,3', not like #{filter}"
    end
  end

  def get(path, query = {})
    self.class.get(path, {
      :headers => { "X-TrackerToken" => @apikey },
      :base_uri => "http://www.pivotaltracker.com/services/v3/projects/#{project_id}",
      :query => query
    })
  end
end

