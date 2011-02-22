class TimeReport
  class Row
    def initialize(values, user_ids)
      @values = values
      @user_ids = user_ids
    end

    def classes
      @values.points_estimate_quality if @values.respond_to? :points_estimate_quality
    end

    def has_column?(name)
      case name
      when Symbol, String
        !@values[name].nil?
      when Numeric
        @values[:time_by_user] && !@values[:time_by_user][name].nil?
      end
    end

    def value_for(column)
      case column
      when Symbol, String
        @values[column]
      when Numeric
        @values[:time_by_user][column]
      end
    end

    def formatted_value_for(column)
      return nil unless has_column? column

      value = value_for(column)

      case column
      when Numeric
        value.to_hours
      when :actual_points
        if value == :blowout then "&inf;"
        else value
        end
      when :time_this_period_percent
        "%.0f %%" % value
      when :time_this_period
        value.to_hours
      when :lifetime_hours
        "%.1f" % value
      when :lifetime_hours_per_point
        "%.1f" % value
      else
        value
      end
    end
  end

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
        nil
      end
    end
  end

  class Task
    TARGET_HOURS_PER_POINT = 5.0
    TARGET_HOURS_PER_POINT_ON_FEATURES = 4.0
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
      when :story_type
        story_type
      when :actual_points
        actual_points
      when :lifetime_hours_per_point
        lifetime_hours_per_point
      else
        @attributes[k]
      end
    end

    def []=(k,v)
      @attributes[k] = v
    end

    def story_type
      @attributes[:story_type] || 'overhead'
    end

    def lifetime_hours_per_point
      if @attributes[:lifetime_hours] && @attributes[:points] && @attributes[:points] > 0
        @attributes[:lifetime_hours] / @attributes[:points]
      end
    end

    def actual_points
      return nil unless self[:story_type] == 'feature' && %w(delivered accepted).include?(self[:status])
      hours = self[:lifetime_hours] || 0
      points = hours / TARGET_HOURS_PER_POINT_ON_FEATURES
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

  NOMINAL_FULL_TEAM_SECONDS_PER_WEEK = 3600 * 6 * 4 * 4 # six hrs/day, four days, four dudes
  SLIMTIMER_TO_PIVOTAL_REGEX = /(\w:\w{3,4}) (\w+)(?: (\d+))$/
  WILDCARD = 'all'

  attr_reader :rows, :users, :project, :period, :subtotal_rows, :total_rows

  def initialize(period, project)
    @period = period
    @project = project

    query_slimtimer(period)
    query_pivotal(period) unless @project.wildcard?
    sort_tasks_by_pivotal_status
    calculate_totals

    user_ids = @users.map &:id
    @rows = @tasks.map { |t| Row.new(t, user_ids) }
    @subtotal_rows = @subtotals.map { |t| Row.new(t, user_ids) }
    @total_rows = [Row.new(@totals, user_ids)]
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
          pivotal_story = @project.pivotal_story($3)
          story = Story.first_or_create(:id => pivotal_story["id"])

          t[:points] = pivotal_story['estimate']
          t[:story_type] = pivotal_story['story_type']
          t[:status] = pivotal_story['current_state']
          t[:pivotal_name] = pivotal_story['name']
          t[:pivotal_story] = story
        rescue Exception => e
          p e
        end
      end
    end

    @tasks
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
end
