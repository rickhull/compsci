require 'compsci/timer'
require 'minitest/autorun'

include CompSci

describe Timer do
  describe "elapsed" do
    it "returns the block value and a positive number" do
      answer, elapsed = Timer.elapsed { sleep 0.01; :foo }
      expect(answer).must_equal :foo
      expect(elapsed).must_be :>, 0
      expect(elapsed).must_be :<, 0.1
    end
  end

  describe "since" do
    it "must be positive" do
      start = Timer.now
      sleep 0.01
      elapsed = Timer.since(start)
      expect(elapsed).must_be :>, 0
      expect(elapsed).must_be :<, 0.1
    end
  end

  describe "loop_avg" do
    it "returns the block value and a positive number" do
      start = Timer.now
      answer, avg_et = Timer.loop_avg(seconds: 0.1) {
        sleep 0.01
        :foo
      }
      elapsed = Timer.since(start)
      expect(answer).must_equal :foo
      expect(avg_et).must_be :>, 0.005
      expect(avg_et).must_be :<, 0.05
      expect(elapsed).must_be :>, 0.05
      expect(elapsed).must_be :<, 0.5
    end

    it "ceases looping after 5 loops" do
      start = Timer.now
      _answer, avg_et = Timer.loop_avg(count: 5) {
        sleep 0.01
      }
      elapsed = Timer.since(start)
      expect(avg_et).must_be :>, 0.005
      expect(avg_et).must_be :<, 0.05
      expect(elapsed).must_be :>, 0.01
      expect(elapsed).must_be :<, 0.1
    end

    it "won't interrupt long loops" do
      start = Timer.now
      _answer, avg_et = Timer.loop_avg(seconds: 0.01) {
        sleep 0.1
      }
      elapsed = Timer.since(start)

      expect(avg_et).must_be :>, 0.05
      expect(avg_et).must_be :<, 0.5
      expect(elapsed).must_be :>, 0.05
      expect(elapsed).must_be :<, 0.5
    end
  end
end
