require 'minitest/autorun'
require 'compsci/date'
require 'date'

describe "CompSci::Date against Ruby's Date" do
  it "matches differences between dates" do
    dates = [[1, 1], [7, 4], [12, 25]]
    years = (1600..3000)

    99.times {
      d1 = [rand(years)] + dates.sample
      d2 = [rand(years)] + dates.sample
    
      rd1, rd2 = Date.new(*d1), Date.new(*d2)
      cd1, cd2 = CompSci::Date.new(*d1), CompSci::Date.new(*d2)

      expect(cd2.diff(cd1)).must_equal (rd2 - rd1)
    }
  end

  it "matches adding a count of days" do
    dates = [[1, 1], [7, 4], [12, 25]]
    years = (1650..3000)
    randsize = 9999

    
    99.times {
      ymd = [rand(years)] + dates.sample
      rd, cd = Date.new(*ymd), CompSci::Date.new(*ymd)
      offset = rand(randsize * 2) - randsize
      rd2 = rd + offset
      cd2 = cd + offset

      expect(cd2.to_s).must_equal rd2.to_s
    }
  end
end
