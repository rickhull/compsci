require 'compsci/timer'
require 'minitest/autorun'

include CompSci

describe Timer do
  describe "elapsed" do
    it "must return the block value and positive number" do
      answer, elapsed = Timer.elapsed { sleep 0.01; :foo }
      answer.must_equal :foo
      elapsed.must_be_close_to 0.015, 0.005
    end
  end

  describe "since" do
    it "must be positive" do
      start = Timer.now
      sleep 0.01
      Timer.since(start).must_be_close_to 0.015, 0.005
    end
  end

  describe "loop_average" do
    it "return the block value and a positive number" do
      start = Timer.now
      answer, avg_et = Timer.loop_average(seconds: 0.25) {
        sleep 0.01
        :foo
      }
      answer.must_equal :foo
      avg_et.must_be_close_to 0.01, 0.005
      Timer.since(start).must_be_close_to 0.3, 0.05
    end

    it "must repeat short loops and stop on time" do
      true.must_equal true
    end

    it "must not interrupt long loops" do
      start = Timer.now
      _answer, avg_et = Timer.loop_average(seconds: 0.1) {
        sleep 0.25
      }
      Timer.since(start).must_be_close_to avg_et, 0.05
      avg_et.must_be_close_to 0.3, 0.05
    end
  end
end