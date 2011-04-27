class TimeReport < Report
  NOMINAL_FULL_TEAM_SECONDS_PER_WEEK = 3600 * 6 * 4 * 4 # six hrs/day, four days, four dudes
  SLIMTIMER_TO_PIVOTAL_REGEX = /(\w:\w{3,4}) (\w+)(?: (\d+))$/
  WILDCARD = 'all'

  attr_reader :rows, :users, :tasks, :project, :period, :subtotal_rows, :total_rows

  def initialize(period, project)
    @period = period
    @project = project

    query_slimtimer(period)
    query_pivotal(period) unless @project.wildcard?
    sort_tasks_by_pivotal_status

    user_ids = users.map &:id
    @rows = @tasks.map { |t| Row.new(t, user_ids) }

    @totals = calculate_totals(@tasks)
    @total_rows = [Row.new(@totals, user_ids)]

    @subtotals = calculate_subtotals(@tasks, @totals)
    @subtotal_rows = @subtotals.map { |t| Row.new(t, user_ids) }
  end

  def project_name
    @project.wildcard? ? 'All projects' : @project.name
  end

  def seconds_per_point_this_period
    if delivered_total[:points] == 0
      1.0 / 0
    else
      total_total[:time_this_period] / delivered_total[:points]
    end
  end

  def period_duration(unit = :seconds)
    seconds = period.end - period.begin
    case unit
    when :seconds
      seconds
    when :weeks
      seconds / 3600 / 24 / 7
    else
      raise "I was looking for :seconds or :weeks"
    end
  end

  def team_strength
    100 * total_total[:time_this_period] / (NOMINAL_FULL_TEAM_SECONDS_PER_WEEK *
                                            period_duration(:weeks))
  end

  # totals
  def delivered_total
    @subtotals.find {|s| s[:name] == "Delivered/Accepted Features" }
  end

  def total_total
    @totals   #.find {|t| t[:name] == "Grand Total" }
  end

private

  def query_slimtimer(range)
    entries = TimeEntry.ending_in(range)
    @users = SlimtimerUser.all(:time_entries => entries, :order => [ :name.asc ])

    @tasks = if @project.wildcard?
      SlimtimerTask.all(:time_entries => entries, :completed => false)
    else
      @project.slimtimer[:ids].
        map    { |id| SlimtimerTask.all(:time_entries => entries, :name.like => "%:#{id}%") }.
        inject { |set, results| set | results }.
        reject { |task| task.support? }
    end

    @tasks = @tasks.group_by(&:canonical_name).map do |name, tasks|
      values = {
        :lifetime_hours => SlimtimerTask.all(:name => tasks.map(&:name).uniq).aggregate(:hours.sum),
        :time_this_period => 0,
        :time_by_user => UserTimeList.new
      }
      tasks.each do |task|
        time_entries = task.time_entries.ending_in(range)
        times = time_entries.aggregate(:duration_in_seconds.sum, :slimtimer_user_id).map(&:reverse)
        values[:time_this_period] += times.inject(0) { |sum, a| sum + a[1] }
        times.each do |user_id, time|
          values[:time_by_user][user_id] += time
        end
      end

      Task.new(name, values)
    end
  end

  def query_pivotal(range)
    return unless @project.has_pivotal_id?

    stories = Pivotal.stories_modified_since(@project.attributes[:pivotal][:id], range.begin.to_date)
    @tasks.each do |t|
      if t[:name] =~ SLIMTIMER_TO_PIVOTAL_REGEX
        begin
          pivotal_story = @project.pivotal_story($3)
          stories = stories.delete_if { |story| story["id"] == pivotal_story["id"] }

          t[:points]         = pivotal_story['estimate']
          t[:story_type]     = pivotal_story['story_type']
          t[:status]         = pivotal_story['current_state']
          t[:pivotal_id]     = pivotal_story['id']
          t[:pivotal_name]   = pivotal_story['name']
          t[:pivotal_story]  = Story.first_or_create(:id => pivotal_story["id"])
          t[:pivotal_labels] = pivotal_story['labels']
        rescue Exception => e
          p e
        end
      end
    end

    open_stories = stories.select { |story| !["unscheduled", "unstarted"].include?(story["current_state"])  }
    open_stories.each do |story|
      @tasks << Task.new("",
        :points           => story['estimate'],
        :story_type       => story['story_type'],
        :status           => story['current_state'],
        :pivotal_id       => story['id'],
        :pivotal_name     => story['name'],
        :pivotal_story    => Story.first_or_create(:id => story["id"]),
        :pivotal_labels   => story['labels'],
        :lifetime_hours   => lifetime_hours_for_task(story['id']),
        :time_this_period => 0,
        :time_by_user     => UserTimeList.new
      )
    end

    @tasks
  end

  def lifetime_hours_for_task(pivotal_id)
    SlimtimerTask.all(:name.like => "%#{pivotal_id}%").aggregate(:hours.sum) || 0
  end

  def sort_tasks_by_pivotal_status
    @tasks.sort!
  end
end
