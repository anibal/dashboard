class SlimtimerTask
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :name, String, :length => 255
  property :hours, Float

  has n, :time_entries

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
  end
end
