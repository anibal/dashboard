class TimeReport
  class Total
    def initialize(name, tasks, total_hours = nil)
      @name = name
      @tasks = tasks
      @total_hours = total_hours
    end

    def [](key)
      case key
      when :time_by_user
        @tasks.map { |task| task[:time_by_user] }.inject(UserTimeList.new) { |sum, val|
          sum ? sum + val : val
        }
      when :name
        @name
      when :points
        @tasks.map { |task| task[:points] || 0 }.sum
      when :lifetime_hours
        @tasks.map { |task| task[:lifetime_hours] }.sum
      when :time_this_period
        @tasks.map { |task| task[:time_this_period] }.sum
      when :time_this_period_percent
        if @total_hours
          self[:time_this_period].to_f / @total_hours.to_f * 100.0
        end
      else
        # Someone's an idiot
        raise "Invalid key for Total#[]: #{key}"
      end
    end
  end

  class Task
    TARGET_HOURS_PER_POINT = 5.0
    POINTS_SCALE = [1,2,3,5,8,13]
    FUDGE_FACTOR = 0.2

    include Comparable

    def initialize(name, attributes = {})
      @name = name
      @attributes = attributes
    end

    def <=>(other)
      # First order by story type
      story_type_order = self[:story_type] <=> other[:story_type]
      # ... then order by status if the story types match
      # HACK use 'zzzzz' to force blanks to the end
      story_type_order == 0 ? (self[:status] || 'zzzzz') <=> (other[:status] || 'zzzzz') : story_type_order
    end

    def [](k)
      case k
      when :name
        @name
      when :actual_points
        actual_points
      else
        @attributes[k]
      end
    end

    def []=(k,v)
      @attributes[k] = v
    end

    def actual_points
      return nil unless self[:story_type] == 'feature' && %w(delivered accepted).include?(self[:status])
      hours = self[:lifetime_hours] || 0
      points = hours / TARGET_HOURS_PER_POINT
      snap_to_points_scale(points)
    end

    def points_estimate_quality
      return '' if actual_points.nil?
      if    blowout?                       then 'blowout'
      elsif self[:points] == actual_points then 'accurate'
      elsif self[:points] > actual_points  then 'overestimate'
      elsif self[:points] < actual_points  then 'underestimate'
      end
    end

    def snap_to_points_scale(points)
      snapped = POINTS_SCALE.select { |v| v * (1 + FUDGE_FACTOR) > points }.min
      snapped || :blowout
    end

    def blowout?; actual_points == :blowout; end

    def bug?;      self[:story_type] == 'bug'; end
    def chore?;    self[:story_type] == 'chore'; end
    def feature?;  self[:story_type] == 'feature'; end
    def overhead?; self[:story_type] == 'overhead'; end

    def delivered?; feature? && %w(delivered accepted).include?(self[:status]); end
    def undelivered?; !delivered?; end
  end

  class UserTimeList
    include Enumerable

    def initialize(time_by_user = {})
      @time_by_user = time_by_user
    end

    def [](user_id)
      @time_by_user[user_id] || 0
    end

    def []=(user_id, time)
      @time_by_user[user_id] = time
    end

    def user_ids
      @time_by_user.keys
    end

    def each(&block)
      @time_by_user.each &block
    end

    def +(other)
      list = UserTimeList.new
      (user_ids + other.user_ids).uniq.each do |user_id|
        list[user_id] = self[user_id] + other[user_id]
      end
      list
    end
  end

  SLIMTIMER_TO_PIVOTAL_REGEX = /(\w:\w{3,4}) (\w+)(?: (\d+))$/
  WILDCARD = 'all'

  attr_reader :tasks, :users, :project, :period, :subtotals, :totals, :team_strength

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
        :lifetime_hours => 0,
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

    lifetime_hours_by_task_name = Hash[*(SlimtimerTask.all.aggregate(:hours.sum, :name).map(&:reverse).flatten)]
    @tasks.each do |t|
      t[:lifetime_hours] = lifetime_hours_by_task_name[t[:name]]
    end
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
    @tasks.sort!
  end

  def calculate_totals
    chores = Total.new('Chores', @tasks.select { |t| t[:story_type] == 'chore' })
    @totals = Total.new('Grand Total', @tasks)

    total_hours = @totals[:time_this_period] - chores[:time_this_period]

    @subtotals = []
    @subtotals << Total.new('Bugs', @tasks.select { |t| t.bug? }, total_hours)
    @subtotals << Total.new('Delivered/Accepted Features', @tasks.select { |t| t.feature? && t.delivered? }, total_hours)
    @subtotals << Total.new('Undelivered Features', @tasks.select { |t| t.feature? && t.undelivered? }, total_hours)
    @subtotals << Total.new('Overhead', @tasks.select { |t| t.overhead? }, total_hours)
    @subtotals << chores
  end

  def calculate_team_strength
    @team_strength = '40%'
  end
end
