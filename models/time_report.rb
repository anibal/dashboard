class TimeReport
  SLIMTIMER_TO_PIVOTAL_REGEX = /(\w:\w{3,4}) (\w+)(?: (\d+))$/
  WILDCARD = 'all'

  attr_reader :tasks, :bug_summary, :users, :project, :period, :totals, :team_strength

  def initialize(period, project)
    @period = period
    @project = project

    query_slimtimer(period)
    query_pivotal(period) unless @project.wildcard?
    mark_unclassified_tasks_as_overhead
    sort_tasks_by_pivotal_status
    calculate_totals
    calculate_team_strength
  end

  def project_name
    @project.wildcard? ? 'All projects' : @project.name
  end

private

  def query_slimtimer(range)
    entries = TimeEntry.ending_in(range)
    @users = SlimtimerUser.all(:time_entries => entries, :order => [ :name.asc ])

    @tasks = if @project.wildcard?
      SlimtimerTask.all(:time_entries => entries, :completed => false)
    else
      @project.slimtimer[:ids].
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
    return unless @project.has_pivotal_id?
    @tasks.each do |t|
      if t[:name] =~ SLIMTIMER_TO_PIVOTAL_REGEX
        begin
          story = @project.pivotal_story($3)
          t[:points] = story['estimate']
          t[:story_type] = story['story_type']
          t[:status] = story['current_state']
          t[:pivotal_name] = story['name']
        rescue Exception => e
          p e
        end
      end
    end

    @tasks
  end

  def mark_unclassified_tasks_as_overhead
    @tasks.each do |task|
      task[:story_type] ||= 'overhead'
    end
  end

  def sort_tasks_by_pivotal_status
    @tasks.sort! do |a,b|
      # First order by story type
      story_type_order = a[:story_type] <=> b[:story_type]
      # ... then order by status if the story types match
      # HACK use 'zzzzz' to force blanks to the end
      story_type_order == 0 ? (a[:status] || 'zzzzz') <=> (b[:status] || 'zzzzz') : story_type_order
    end
  end

  def totals_for_story_type(type)
    stories = @tasks.select { |task| task[:story_type] == type }

    user_times = Hash.new { |h,k| h[k] = 0 }
    stories.map { |bug| bug[:time_by_user] }.each do |user_id, hours|
      user_times[user_id] += hours if hours
    end
    { :name => type,
      :points => stories.map { |story| story[:points] || 0 }.sum,
      :lifetime_hours => stories.map { |story| story[:lifetime_hours] }.sum,
      :time_this_period => stories.map { |story| story[:time_this_period] }.sum,
      :time_by_user => user_times
    }
  end

  def calculate_totals
    @totals = {}
    %w(bug chore feature overhead).each do |type|
      @totals[type] = totals_for_story_type(type)
    end
  end

  def calculate_team_strength
    @team_strength = '40%'
  end
end
