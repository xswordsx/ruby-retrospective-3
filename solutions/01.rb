class Integer

  def prime?
    return false if self < 2
    (2..Math.sqrt(self)).all? {|x| remainder(x).nonzero?}
  end

  def prime_factors
    return [] if self == 1
    factor = (2..abs).find {|x| x.prime? and remainder(x).zero?}
    [factor] + (abs / factor).prime_factors
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end

  def harmonic
    (1..self).reduce {|sum, x| sum + Rational(1, x)}
  end

end

class Array
  def average
    reduce(:+) / length.to_f
  end
end