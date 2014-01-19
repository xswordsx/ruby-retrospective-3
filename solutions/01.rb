class Integer

  def prime?
    return false if self < 2
    (2..Math.sqrt(self)).all? {|x| remainder(x).nonzero?}
  end

  def digits
    abs.to_s.chars.map(&to_i)
  end

end