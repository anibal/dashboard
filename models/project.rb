class Project
  def self.all
    PROJECTS.map do |id, attributes|
      new id, attributes
    end
  end

  attr_accessor :id, :attributes

  def initialize(id, attributes)
    @id = id
    @attributes = attributes.clone
  end

  def iteration_dates
    @iteration_dates ||= Pivotal.status_for(@attributes[:pivotal])
  end

  def prev_iteration
    @attributes[:prev_iteration] ||= iteration_dates.last
  end

  def curr_iteration
    @attributes[:curr_iteration] ||= [iteration_dates.last.last, Time.now] rescue nil
  end

  def method_missing(method, *args, &blk)
    if @attributes.has_key? method
      @attributes[method]
    else
      super
    end
  end
end
