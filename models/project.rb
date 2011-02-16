require 'active_support'

class Project
  WILDCARD_ID = 'all'

  def self.all
    @all ||= PROJECTS.map do |id, attributes|
      new id, attributes
    end
  end

  def self.find(id)
    return WildCardProject.new if id == WILDCARD_ID

    all.find { |project| project.id == id }
  end

  attr_accessor :id, :attributes

  def initialize(id, attributes)
    @id = id
    @attributes = attributes.clone
  end

  def wildcard?
    false
  end

  def iteration_dates
    @iteration_dates ||= Pivotal.status_for(@attributes[:pivotal])
  end

  def prev_iteration
    @attributes[:prev_iteration] ||= dates_to_beginning_of_day(iteration_dates.last)
  end

  def curr_iteration
    @attributes[:curr_iteration] ||= dates_to_beginning_of_day([iteration_dates.last.last,
                                                                    Time.now]) rescue nil
  end

  def method_missing(method, *args, &blk)
    if @attributes.has_key? method
      @attributes[method]
    else
      super
    end
  end

  def pivotal_story(id)
    Pivotal.story(attributes[:pivotal][:id], id)
  end

  def has_pivotal_id?
    @attributes[:pivotal] && @attributes[:pivotal][:id]
  end

  def shepherd
    shepherd = Shepherd.first(:project => id)
    shepherd && shepherd.name
  end

  private

  def dates_to_beginning_of_day(dates)
    it_start, it_end = dates
    return nil unless it_start && it_end
    it_start, it_end = [it_start.beginning_of_day, it_end.beginning_of_day]
    [it_start, it_end]
  end
end

class WildCardProject < Project
  def initialize
    super(WILDCARD_ID, {})
  end

  def wildcard?
    true
  end
end
