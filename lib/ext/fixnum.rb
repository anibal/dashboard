class Fixnum
  def to_time
    time = []
    time << "%02d" % (self / 3600) if self >= 3600
    time << "%02d" % ((self % 3600) / 60)
    time << "%02d" % (self % 60)
    "-" + time.join(":")
  end

  def to_hours
    "%.1f" % (self / 3600.0)
  end
end
