class Report
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

    def name
      @values[:name]
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
          sum ? (sum + val) : val
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

    def initialize(users = [])
      @time_by_user = {}
      users.each { |u| @time_by_user[u.id] = 0 }
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

protected

  def calculate_totals(tasks)
    Total.new('Grand Total', tasks)
  end

  def calculate_subtotals(tasks, totals)
    chores = Total.new('Chores', tasks.select { |t| t[:story_type] == 'chore' })
    total_hours = totals[:time_this_period] - chores[:time_this_period]

    subtotals = []
    subtotals << Total.new('Bugs', tasks.select { |t| t.bug? }, total_hours)
    subtotals << Total.new('Delivered/Accepted Features', tasks.select { |t| t.feature? && t.delivered? }, total_hours)
    subtotals << Total.new('Undelivered Features', tasks.select { |t| t.feature? && t.undelivered? }, total_hours)
    subtotals << Total.new('Overhead', tasks.select { |t| t.overhead? }, total_hours)
    subtotals << chores
  end
end
