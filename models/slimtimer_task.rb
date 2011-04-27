class SlimtimerTask
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :name, String, :length => 255
  property :hours, Float
  property :completed, Boolean

  has n, :time_entries

  def support?
    name =~ /^s:/
  end

  # The most-recent canonical format of this task name.
  # e.g. Time clocked against "t:jas docs" is now clocked against "i:jas docs",
  # so "i:jas" is now the canonical form of "t:jas".
  def canonical_name
    cname = name.dup

    # make sure old i-class tasks now start with i
    cname.gsub! /^t:(dma|jas|kud|pbk|plan|pod|rad) (.*)$/, 'i:\1 \2'

    cname
  end

  def self.update(tasks)
    tasks.each do |task_attributes|
      task = get(task_attributes['id']) || new
      task.update_from_slimtimer(task_attributes)
      task.save
    end
  end

  def update_from_slimtimer(attributes)
    self.id = attributes['id']
    self.name = attributes['name']
    self.hours = attributes['hours']
    self.completed = !attributes['completed_on'].blank?
  end
end
