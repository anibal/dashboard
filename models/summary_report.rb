class SummaryReport < Report

  attr_reader :reports, :subtotal_rows, :total_rows, :period

  def initialize(period)
    @period = period

    @reports = []
    Project.all.each do |project|
      time_report = TimeReport.new(period, project)
      @reports << time_report unless time_report.rows.empty?
    end

    calculate_totals

    user_ids = users.map &:id
    @subtotal_rows = @subtotals.map { |t| Row.new(t, user_ids) }
    @total_rows = [Row.new(@totals, user_ids)]
  end

  def users
    @reports.map(&:users).flatten.uniq
  end

  def tasks
    @reports.map(&:tasks).flatten.uniq
  end

  def calculate_totals
    chores = Total.new('Chores', tasks.select { |t| t[:story_type] == 'chore' })
    @totals = Total.new('Grand Total', tasks)

    total_hours = @totals[:time_this_period] - chores[:time_this_period]

    @subtotals = []
    @subtotals << Total.new('Bugs', tasks.select { |t| t.bug? }, total_hours)
    @subtotals << Total.new('Delivered/Accepted Features', tasks.select { |t| t.feature? && t.delivered? }, total_hours)
    @subtotals << Total.new('Undelivered Features', tasks.select { |t| t.feature? && t.undelivered? }, total_hours)
    @subtotals << Total.new('Overhead', tasks.select { |t| t.overhead? }, total_hours)
    @subtotals << chores
  end
end
