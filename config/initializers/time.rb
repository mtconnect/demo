class Time
  def prev_hour
    self - 1.hours
  end

  def next_hour
    self + 1.hours
  end
end
