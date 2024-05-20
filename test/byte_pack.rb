require 'minitest/autorun'
require 'compsci/byte_pack'

include CompSci

describe BytePack do
  VAL = [rand(999999999)].pack('N*')
  HEXVAL = VAL.unpack1('H*')

  it "converts an arbitrary length binary string to an array of ints" do
    ary = BytePack.bin2ints(VAL)
    expect(ary).must_be_kind_of Enumerable
    ary.each { |i|
      expect(i).must_be_kind_of Integer
      expect(i).must_be :>, 0
    }
  end

  it "converts an arbitrary length hex string to an array of ints" do
    ary = BytePack.hex2ints(HEXVAL)
    expect(ary).must_be_kind_of Enumerable
    ary.each { |i|
      expect(i).must_be_kind_of Integer
      expect(i).must_be :>, 0
    }
  end

  it "converts an arbitrary length binary string to a hex string" do
    hex = BytePack.bin2hex(VAL)
    expect(hex).must_be_kind_of String
    expect(hex).wont_be_empty
    expect(hex.match(/\A[0-9a-f]+\z/)).must_be_kind_of MatchData
  end

  it "converts an arbitrary length hex string to a binary string" do
    str = BytePack.hex2bin(HEXVAL)
    expect(str).must_be_kind_of String
    expect(str).wont_be_empty
    expect(str.encoding) == Encoding::BINARY
  end

  it "can be initialized with a binary string" do
    b = BytePack.new("\xff\x00")
    expect(b).must_be_kind_of BytePack
    expect(b.hex).must_equal "ff00"
  end

  it "can be initialized with a hex string" do
    b = BytePack.new(hex: "00ff")
    expect(b).must_be_kind_of BytePack
    expect(b.storage).must_equal "\x00\xFF".b
  end

  it "can be initialized with a single int or an array of ints" do
    b = BytePack.new(int: 65535)
    expect(b).must_be_kind_of BytePack
    expect(b[0]).must_equal 65535

    b = BytePack.new(int: [1, 2, 3, 4])
    expect(b).must_be_kind_of BytePack
    expect(b.ints).must_equal [1, 2, 3, 4]
  end

  it "can be initialized with no params" do
    b = BytePack.new
    expect(b).must_be_kind_of BytePack
    expect(b.storage).must_be_empty
  end

  it "prepares incoming binary strings before unpacking to ints" do
    s = BytePack.prepare('asdf')
    expect(s.encoding).must_equal Encoding::BINARY
    expect(s.bytesize).must_equal BytePack::NATIVE
  end
end
