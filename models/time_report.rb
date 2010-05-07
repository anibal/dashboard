class TimeReport
  SLIMTIMER_TO_PIVOTAL_REGEX = /(\w:\w{3,4}) (\w+)(?: (\d+))$/

  attr_reader :tasks, :users, :project, :period

  def initialize(period, project)
    @period = period
    @project = PROJECTS[project]
    query_slimtimer(period)
    query_pivotal(period)
  end

  def project_name
    @project[:name]
  end

  private
  def query_slimtimer(range)
    entries = TimeEntry.ending_in(range)
    @users = SlimtimerUser.all(:time_entries => entries, :order => [ :name.asc ])

    @tasks = SlimtimerTask.all(:time_entries => entries, :name.like => "#{@project[:slimtimer]}%")
    pp @tasks
    @tasks = @tasks.map do |task|
      times = task.time_entries.ending_in(range).aggregate(:duration_in_seconds.sum, :slimtimer_user_id).map { |a| a.reverse }
      { :name => task.name,
        :lifetime_hours => task.hours,
        :time_this_period => times.inject(0) { |sum, a| sum + a[1] },
        :time_by_user => times
      }
    end
  end

  def query_pivotal(range)
    return unless @project[:pivotal][:id]
    pivotal = PivotalApi.new(PIVOTAL_TOKEN, @project[:pivotal][:id])
    @tasks.each do |t|
      if t[:name] =~ SLIMTIMER_TO_PIVOTAL_REGEX
        begin
          story = pivotal.story($3)
          t[:points] = story['estimate']
          t[:story_type] = story['story_type']
          t[:status] = story['current_state']
          t[:pivotal_name] = story['name']
        rescue Exception => e
          p e
        end
      end
    end
  end
end
