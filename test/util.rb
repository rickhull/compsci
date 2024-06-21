require 'compsci/util'
require 'minitest/autorun'

describe CompSci do
  parallelize_me!

  it "determines if num is a power of base" do
    powers = Hash.new []
    basemax = 12
    expmax = 10
    2.upto(basemax) { |base|
      0.upto(expmax) { |exp|
        powers[base] += [base**exp]
      }
    }

    # 12k assertions below!
    2.upto(basemax) { |base|
      1.upto(2**expmax) { |num|
        x = powers[base].include?(num)
        expect(CompSci.power_of?(num, base)).must_equal x
      }
    }
  end
end
