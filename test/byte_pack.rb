require 'minitest/autorun'
require 'compsci/byte_pack'

include CompSci

describe BytePack do
  VAL = [rand(999999999)].pack('N*')
  HEXVAL = VAL.unpack1('H*')
  B64VAL = [VAL].pack('m0')

  it "converts a binary string to an array of ints" do
    ary = BytePack.bin2ints(VAL)
    expect(ary).must_be_kind_of Array
    ary.each { |i|
      expect(i).must_be_kind_of Integer
      expect(i).must_be :>, 0
    }
  end

  it "converts an array of ints to a binary string" do
    str = BytePack.ints2bin([1,2,3,4])
    expect(str).must_be_kind_of String
    expect(str).wont_be_empty
    expect(str.encoding) == Encoding::BINARY
  end

  it "converts a binary string to a hex string" do
    hex = BytePack.bin2hex(VAL)
    expect(hex).must_be_kind_of String
    expect(hex).wont_be_empty
    expect(hex.match(/\A[0-9a-f]+\z/)).must_be_kind_of MatchData
  end

  it "converts a hex string to a binary string" do
    str = BytePack.hex2bin(HEXVAL)
    expect(str).must_be_kind_of String
    expect(str).wont_be_empty
    expect(str.encoding) == Encoding::BINARY
  end

  it "converts a binary string to a base64 string" do
    b64 = BytePack.bin2b64(VAL)
    expect(b64).must_be_kind_of String
    expect(b64).wont_be_empty
    expect(b64.encoding).must_equal Encoding::US_ASCII
  end

  it "converts a base64 string to a binary string" do
    str = BytePack.b642bin(B64VAL)
    expect(str).must_be_kind_of String
    expect(str).wont_be_empty
    expect(str.encoding) == Encoding::BINARY
  end

  it "converts a hex string to an array of ints" do
    ary = BytePack.bin2ints(BytePack.hex2bin(HEXVAL))
    expect(ary).must_be_kind_of Array
    ary.each { |i|
      expect(i).must_be_kind_of Integer
      expect(i).must_be :>, 0
    }
  end

  it "converts an array of ints to a hex string" do
    hex = BytePack.bin2hex(BytePack.ints2bin([1,2,3,4]))
    expect(hex).must_be_kind_of String
    expect(hex).wont_be_empty
    expect(hex.match(/\A[0-9a-f]+\z/)).must_be_kind_of MatchData
  end

  it "can be initialized without params" do
    b = BytePack.new
    expect(b).must_be_kind_of BytePack
    expect(b.storage).must_be_empty
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

  it "can be initialized with a base64 string" do
    b = BytePack.new(base64: "aGVsbG8gd29ybGQ=")
    expect(b.storage).must_equal "hello world".b
  end

  it "can be initialized with a single int or an array of ints" do
    b = BytePack.new(net: 65535)
    expect(b).must_be_kind_of BytePack
    expect(b[0]).must_equal 65535

    b = BytePack.new(net: [1, 2, 3, 4])
    expect(b).must_be_kind_of BytePack
    expect(b.net).must_equal [1, 2, 3, 4]

    b = BytePack.new(int: 65535)
    expect(b).must_be_kind_of BytePack
    expect(b.ints[0]).must_equal 65535

    b = BytePack.new(int: [1, 2, 3, 4])
    expect(b).must_be_kind_of BytePack
    expect(b.ints).must_equal [1, 2, 3, 4]
  end

  it "prepares incoming binary strings before unpacking to ints" do
    ['asdf', "\x00\xFF"].each { |str|
      s = BytePack.prepare(str)
      expect(s.encoding).must_equal Encoding::BINARY
      expect(s.bytesize).must_equal BytePack::NATIVE
    }

    val = "\xFF\x00"

    str = BytePack.prepare(val, width: 4, endian: :little)
    expect(str.length).must_equal 4
    expect(str).must_equal "\xFF\x00\x00\x00".b

    str = BytePack.prepare(val, width: 8, endian: :big)
    expect(str.length).must_equal 8
    expect(str).must_equal "\x00\x00\x00\x00\x00\x00\xFF\x00".b

    str = BytePack.prepare(val.b, width: 2)
    expect(str).must_equal val.b
  end
end
