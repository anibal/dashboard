require 'slimtimer4r'

class ST

  class << self
    def status_for(status, from, to)
      st_connection = SlimTimer.new(SLIMTIMER_USER, SLIMTIMER_PW, SLIMTIMER_TOKEN)

      from ||= Date.today - 31
      to   ||= Date.today
      entries = st_connection.list_timeentries(from - 21, to).select { |entry| entry.task.name =~ /:#{status[:id]} / }
      duration = (entries.map { |entry| entry.duration_in_seconds }.inject(0) { |sum, duration| sum + duration } / 60.0)

      status.merge!(
        :hours => duration.round,
        :average => (duration / 4.0).round
      )
    end
  end
end
