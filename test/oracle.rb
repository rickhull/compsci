require 'compsci/oracle'
require 'minitest/autorun'

include CompSci::Oracle

describe CompSci::Oracle do
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
    end

    it "tracks next-letter frequencies" do
    end

    it "makes predictions" do
    end
  end
end
