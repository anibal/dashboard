class Array
  def sum
    self.inject(0) { |sum, val| sum + val }
  end
end