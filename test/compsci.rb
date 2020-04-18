require 'compsci'
require 'minitest/autorun'

Minitest::Test.parallelize_me!

describe CompSci do
  it "must determine if num is a power of base" do
    powers = {}
    basemax = 12
    expmax = 10
    2.upto(basemax) { |base|
      0.upto(expmax) { |exp|
        powers[base] ||= []
        powers[base] << base**exp
      }
    }

    # 12k assertions below!
    2.upto(basemax) { |base|
      1.upto(2**expmax) { |num|
        expect(CompSci.power_of?(num, base)).must_equal powers[base].include?(num)
      }
    }
  end
end
