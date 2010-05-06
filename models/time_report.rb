class TimeReport
  SLIMTIMER_TO_PIVOTAL_REGEX = /(\w:\w{3,4}) (\w+)(?: (\d+))$/

  attr_reader :tasks, :users

  def initialize(range, project)
    query_slimtimer(range, project)
    query_pivotal(range, project)
  end

  private
  def query_slimtimer(range, project)
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

  def query_pivotal(range, project)
    return unless project[:pivotal][:id]
    pivotal = PivotalApi.new(PIVOTAL_TOKEN, project[:pivotal][:id])
    @tasks.each do |t|
      if t[:name] =~ SLIMTIMER_TO_PIVOTAL_REGEX
        pp pivotal.stories("id:#{$3}")
      end
    end
  end
end
