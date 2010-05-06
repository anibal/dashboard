class TimeReport
  attr_reader :tasks, :users

  def initialize(range)
    entries = TimeEntry.ending_in(range)
    @users = SlimtimerUser.all(:time_entries => entries, :order => [ :name.asc ])

    @tasks = SlimtimerTask.all(:time_entries => entries)
    pp @tasks
    @tasks = @tasks.map do |task|
      { :name => task.name,
        :lifetime_hours => task.hours,
        :time_by_user => task.time_entries.ending_in(range).aggregate(:duration_in_seconds.sum, :slimtimer_user_id).map { |a| a.reverse }
      }
    end
  end
end
