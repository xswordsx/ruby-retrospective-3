class Integer

  def prime?
    return false if self < 2
    (2..Math.sqrt(self)).all? {|x| (self % x) != 0}
  end

end