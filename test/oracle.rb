require 'compsci/oracle'
require 'minitest/autorun'

include CompSci::Oracle

describe CompSci::Oracle do
  parallelize_me!

  describe Ring do
    it "has a limited number of slots" do
      r = Ring.new(3)
      expect(r.count).must_equal 3
      expect(r.storage.count).wont_equal 3
      expect(r.storage.count).must_equal 0

      r.update(1)
      r.update(2)
      expect(r.full?).must_equal false

      r.update(3)
      expect(r.storage.count).must_equal 3
      expect(r.full?).must_equal true

      r.update(4)
      expect(r.storage.count).must_equal 3
      expect(r.full?).must_equal true

      expect(r.to_s).must_equal '234'
      expect(r.storage).must_equal [4, 2, 3]
    end
  end

  describe Model do
    it "has a ring" do
      m = Model.new
      expect(m.ring).must_be_kind_of Ring

      m.accept('12345')
      str = m.ring.to_s
      expect(str).must_be_kind_of String
      expect(str.length).must_equal 5
      expect(str).must_equal '12345'

      m.accept('6')
      str = m.ring.to_s
      expect(str).must_be_kind_of String
      expect(str.length).must_equal 5
      expect(str).must_equal '23456'
    end

    it "tracks next-letter frequencies" do
      m = Model.new(3)
      m.accept('111')
      expect(m.freq['111']).must_be_nil

      m.accept('1')
      expect(m.freq['111']).wont_be_nil
      expect(m.freq['111']).must_equal({'1' => 1})

      m.accept('1')
      expect(m.freq['111']).wont_be_nil
      expect(m.freq['111']).must_equal({'1' => 2})

      m.accept('2')
      expect(m.freq['111']).must_equal({'1' => 2, '2' => 1})

      m.accept('3')
      expect(m.freq['112']).must_equal({'3' => 1})
    end

    it "makes predictions" do
      m = Model.new(3)
      m.accept('111')
      expect(m.ring.to_s).must_equal '111'
      expect(m.freq['111']).must_be_nil
      expect(m.prediction).must_be_nil

      m.accept('1')
      expect(m.ring.to_s).must_equal '111'
      pred = m.prediction
      expect(pred).wont_be_nil
      expect(pred[:best_key]).must_equal '1'
      expect(pred[:best_val]).must_equal 1
      expect(pred[:best_pct]).must_equal 1.0
      expect(pred[:top]['1']).must_equal 1.0

      m.accept('2')
      expect(m.ring.to_s).must_equal '112'
      expect(m.prediction).must_be_nil

      m.accept('3112')
      expect(m.ring.to_s).must_equal '112'
      pred = m.prediction
      expect(pred).wont_be_nil
      expect(pred[:best_key]).must_equal '3'
      expect(pred[:best_val]).must_equal 1
      expect(pred[:best_pct]).must_equal 1.0
      expect(pred[:top]['3']).must_equal 1.0
    end
  end
end
