require 'compsci/timer'
require 'minitest/autorun'

include CompSci

describe Timer do
  describe "elapsed" do
    it "must return the block value and positive number" do
      answer, elapsed = Timer.elapsed { sleep 0.01; :foo }
      expect(answer).must_equal :foo
      expect(elapsed).must_be_close_to 0.015, 0.01
    end
  end

  describe "since" do
    it "must be positive" do
      start = Timer.now
      sleep 0.01
      expect(Timer.since(start)).must_be_close_to 0.015, 0.01
    end
  end

  describe "loop_avg" do
    it "return the block value and a positive number" do
      start = Timer.now
      answer, avg_et = Timer.loop_avg(seconds: 0.1) {
        sleep 0.01
        :foo
      }
      expect(answer).must_equal :foo
      expect(avg_et).must_be_close_to 0.01, 0.005
      expect(Timer.since(start)).must_be_close_to 0.15, 0.05
    end

    it "must repeat short loops and stop on time" do
      # see above, Timer.since(start)
      true
    end

    it "must cease looping after 5 loops" do
      start = Timer.now
      _answer, avg_et = Timer.loop_avg(count: 5) {
        sleep 0.01
      }
      expect(avg_et).must_be_close_to 0.015, 0.005
      expect(Timer.since(start)).must_be_close_to 0.1, 0.05
    end

    it "must not interrupt long loops" do
      start = Timer.now
      _answer, avg_et = Timer.loop_avg(seconds: 0.01) {
        sleep 0.1
      }
      expect(Timer.since(start)).must_be_close_to avg_et, 0.05
      expect(avg_et).must_be_close_to 0.15, 0.05
    end
  end
end
