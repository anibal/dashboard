class SlimtimerUser
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :name, String
  property :email, String

  has n, :time_entries

  def update_time_entries(entries)
    entries.each do |entry_attributes|
      entry = time_entries.get(entry_attributes['id']) || time_entries.new
      entry.update_from_slimtimer(entry_attributes)
      entry.save
    end
  end
end

