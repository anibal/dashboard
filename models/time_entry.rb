class TimeEntry
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :slimtimer_task_id, Integer
  property :slimtimer_user_id, Integer
  property :start_time, DateTime
  property :end_time, DateTime
  property :duration_in_seconds, Integer
  property :comments, Text
  property :tags, Text

  belongs_to :slimtimer_task
  belongs_to :slimtimer_user

  def self.ending_in(range)
    all(:end_time => range)
  end

  def update_from_slimtimer(attributes)
    self.id                  = attributes['id']
    self.slimtimer_task_id   = attributes['task']['id']
    self.start_time          = attributes['start_time']
    self.end_time            = attributes['end_time']
    self.duration_in_seconds = attributes['duration_in_seconds']
    self.comments            = attributes['comments']
    self.tags                = attributes['tags']
  end
end
