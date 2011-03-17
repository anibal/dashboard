class SummaryReport < Report

  attr_reader :reports, :subtotal_rows, :total_rows, :period

  def initialize(period)
    @period = period

    @reports = []
    Project.all.each do |project|
      time_report = TimeReport.new(period, project)
      @reports << time_report unless time_report.rows.empty?
    end

    user_ids = users.map &:id

    totals = calculate_totals(tasks)
    @total_rows = [Row.new(totals, user_ids)]

    subtotals = calculate_subtotals(tasks, totals)
    @subtotal_rows = subtotals.map { |t| Row.new(t, user_ids) }
  end

  def users
    @reports.map(&:users).flatten.uniq
  end

  def tasks
    @reports.map(&:tasks).flatten.uniq
  end
end
