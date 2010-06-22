class TimeReport
  SLIMTIMER_TO_PIVOTAL_REGEX = /(\w:\w{3,4}) (\w+)(?: (\d+))$/
  WILDCARD = 'all'

  attr_reader :tasks, :bug_summary, :users, :project, :period

  def initialize(period, project)
    @period = period
    @project = PROJECTS[project]
    @is_wildcard = (project == WILDCARD)

    query_slimtimer(period)
    query_pivotal(period) unless @is_wildcard
  end

  def project_name
    @is_wildcard ? 'All projects' : @project[:name]
  end

  private
  def query_slimtimer(range)
    entries = TimeEntry.ending_in(range)
    @users = SlimtimerUser.all(:time_entries => entries, :order => [ :name.asc ])

    @tasks = if @is_wildcard
      SlimtimerTask.all(:time_entries => entries, :completed => false)
    else
      @project[:slimtimer][:ids].
        map { |id| SlimtimerTask.all(:time_entries => entries, :name.like => "%:#{id} %") }.
        inject { |set, results| set | results }
    end

    @tasks = @tasks.group_by(&:name).map do |name, tasks|
      values = {
        :name => name,
        :lifetime_hours => 0,
        :time_this_period => 0,
        :time_by_user => Hash.new { |h,k| h[k] = 0 }
      }
      tasks.each do |task|
        time_entries = task.time_entries.ending_in(range)
        times = time_entries.aggregate(:duration_in_seconds.sum, :slimtimer_user_id).map(&:reverse)
        values[:time_this_period] += times.inject(0) { |sum, a| sum + a[1] }
        times.each do |user_id, time|
          values[:time_by_user][user_id] += time
        end
      end
      values
    end

    lifetime_hours_by_task_name = Hash[*(SlimtimerTask.all.aggregate(:hours.sum, :name).map(&:reverse).flatten)]
    @tasks.each do |t|
      t[:lifetime_hours] = lifetime_hours_by_task_name[t[:name]]
    end

    @tasks.sort! { |a,b| a[:name] <=> b[:name] }

    @bug_summary = {
      :name => "",
      :lifetime_hours => 0,
      :time_this_period => 0,
      :time_by_user => {}
    }
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

    bugs = @tasks.select { |task| task[:story_type] == "bug" }

    user_times = Hash.new { |h,k| h[k] = 0 }
    bugs.map { |bug| bug[:time_by_user] }.each do |user_id, hours|
      user_times[user_id] += hours if hours
    end
    @bug_summary = {
      :name => "Bugs",
      :lifetime_hours => bugs.map { |bug| bug[:lifetime_hours] }.sum,
      :time_this_period => bugs.map { |bug| bug[:time_this_period] }.sum,
      :time_by_user => user_times
    }

    @tasks
  end
end
