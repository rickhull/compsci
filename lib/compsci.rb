module CompSci
  # thanks apeiros
  # https://gist.github.com/rickhull/d0b579aa08c85430b0dc82a791ff12d6
  def self.power_of?(num, base)
    return false if base <= 1
    mod = 0
    num, mod = num.divmod(base) until num == 1 || mod > 0
    mod == 0
  end
end
