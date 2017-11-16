require 'compsci/names'

module CompSci::Names::Pokemon
  DATAFILE = File.join(__dir__, 'pokemon.txt')

  def self.array
    @@array ||= self.read_file
    @@array
  end

  def self.hash
    @@hash ||= self.read_hash
    @@hash
  end

  # an array of all the names
  def self.read_file(path: DATAFILE)
    File.readlines(path).map { |n| n.chomp }
  end

  # return an array, possibly empty, if all: true
  # return a string, possibly nil, if all: false
  def self.grep(rgx, path: DATAFILE, all: false)
    ary = []
    File.open(path).each_line { |l|
      if l.match rgx
        ary << l.chomp
        break unless all
      end
    }
    all ? ary : ary.first
  end

  # a hash of all the names, keyed by the first letter
  def self.read_hash(path: DATAFILE)
    hsh = Hash.new { |h, k| h[k] = [] }
    File.open(path).each_line { |l|
      hsh[l[0]] << l.chomp
    }
    hsh
  end

  # convert 0-25 to a lowercase alpha
  def self.key(val)
    if val.is_a?(String)
      if val.match(/^[0-9]/)
        val = val[0..1].to_i
      elsif val.match(/^[a-z]/i)
        return val.downcase[0]
      else
        raise(ArgumentError, "can't handle #{val}")
      end
    end
    CompSci::Names::ENGLISH_LOWER[val.to_i]
  end

  # return a pokemon sampled from those keyed by val
  def self.sample(val)
    self.hash[self.key(val)]&.sample
  end
end
