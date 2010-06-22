class Slimtimer

  class << self
    def status_for(status, iteration_dates)
      tasks = status[:ids].inject([]) { |set, id| set | SlimtimerTask.all(:name.like => "%:#{id} %") }

      if iteration_dates && !tasks.empty?
        iteration_seconds = []
        iteration_dates.each do |dates|
          iteration_seconds << tasks.time_entries.all(:start_time.gt => dates[0], :start_time.lt => dates[1]).sum(:duration_in_seconds)
        end
        iteration_seconds.compact!

        total_hours = ((iteration_seconds.inject { |sum, sec| sum + sec } || 0) / 3600)
        status.merge!(
          :hours         => total_hours,
          :average_hours => (total_hours / [iteration_seconds.size, 1].max)
        )
      else
        status.merge!(
          :hours         => 0,
          :average_hours => 0
        )
      end
    end
  end
end
