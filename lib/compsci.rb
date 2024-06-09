module CompSci
  NEWLINE = $/ # platform-default line separator

  # thanks apeiros
  # https://gist.github.com/rickhull/d0b579aa08c85430b0dc82a791ff12d6
  def self.power_of?(num, base)
    return false if base <= 1
    mod = 0
    num, mod = num.divmod(base) until num == 1 || mod > 0
    mod == 0
  end

  def self.numeric!(num)
    raise(ArgumentError, num.inspect) unless num.is_a?(Numeric)
    num
  end

  def self.positive!(num)
    numeric!(num)
    raise(ArgumentError, num.inspect) unless num >= 0
    num
  end

  def self.string!(str)
    raise(ArgumentError, str.inspect) unless str.is_a?(String)
    str
  end

  def self.nonempty!(str)
    string!(str)
    raise(ArgumentError, str.inspect) if str.empty?
    str
  end
end
