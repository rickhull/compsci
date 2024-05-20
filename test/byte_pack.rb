require 'minitest/autorun'
require 'compsci/byte_pack'

include CompSci

describe BytePack do
  it "converts an arbitrary length binary string to an array of ints" do
    valid = {
      "\xff" => [255],
      "\xff\x00" => [255],
      "\x00\xff" => [65280],
      "\x00\x00\x00\x01" => [16777216],
      "\x01\x00\x00\x01" => [16777217],
    }

    invalid = {
      "\xff\x00" => [65280],
      "\x00\xff" => [255],
    }

    valid.each { |str, ints|
      expect(BytePack.bin2ints(str)).must_equal ints
    }

    invalid.each { |str, ints|
      expect(BytePack.bin2ints(str)).wont_equal ints
    }
  end

  it "converts an arbitrary length hex string to an array of ints" do
    valid = {
      "ff" => [255],
      "ff00" => [255],
      "00ff" => [65280],
      "00000001" => [16777216],
      "01000001" => [16777217],
    }

    invalid = {
      "ff00" => [65280],
      "00ff" => [255],
    }

    valid.each { |str, ints|
      expect(BytePack.hex2ints(str)).must_equal ints
    }

    invalid.each { |str, ints|
      expect(BytePack.hex2ints(str)).wont_equal ints
    }
  end

  it "converts an arbitrary length binary string to a hex string" do
    valid = {
      "\xff" => "ff",
      "\xff\x00" => "ff00",
      "\x00\xff" => "00ff",
      "\x00\x00\x00\x01" => "00000001",
      "\x01\x00\x00\x01" => "01000001",
    }

    invalid = {
      "\xff\x00" => "00ff",
      "\x00\xff" => "ff00",
    }

    valid.each { |str, hex|
      expect(BytePack.bin2hex(str)).must_equal hex
    }

    invalid.each { |str, hex|
      expect(BytePack.bin2hex(str)).wont_equal hex
    }
  end

  it "converts an arbitrary length hex string to a binary string" do
    valid = {
      "ff" => "\xFF",
      "ff00" => "\xFF\x00",
      "00ff" => "\x00\xFF",
      "00000001" => "\x00\x00\x00\x01",
      "01000001" => "\x01\x00\x00\x01",
    }

    invalid = {
      "ff00" => "\x00\xFF",
      "00ff" => "\xFF\x00",
    }

    valid.each { |hex, str|
      expect(BytePack.hex2bin(hex)).must_equal str.b
    }

    invalid.each { |hex, str|
      expect(BytePack.hex2bin(hex)).wont_equal str.b
    }
  end

  it "represents binary data with least significant byte first" do
    valid = {
      "\xff" => 255,
      "\xff\x00" => 255,
      "\x00\xff" => 65280,
    }

    invalid = {
      "\xff" => 65280,
      "\xff\x00" => 65280,
      "\x00\xff" => 255,
    }

    valid.each { |str, int|
      expect(BytePack.bin2ints(str).first).must_equal int
    }

    invalid.each { |str, int|
      expect(BytePack.bin2ints(str).first).wont_equal int
    }
  end

  it "differs from Ruby convention which puts most significant byte first" do
    valid_ruby = {
      255 => [0xff, 0x00ff, 0x0000ff, 'ff'],
      65280 => [0xff00, 0x00ff00, 0x0000ff00, 'ff00'],
    }

    valid_ruby.each { |dec, ary|
      ary.each { |val|
        if val.is_a?(String)
          expect(dec.to_s(16)).must_equal val
        else
          expect(dec).must_equal val
        end
      }
    }
  end

  it "can be initialized with a binary string" do
    b = BytePack.new("\xff\x00")
    expect(b).must_be_kind_of BytePack
    expect(b.storage.first).must_equal 255
  end

  it "can be initialized with a hex string" do
    b = BytePack.new(hex: "00ff")
    expect(b).must_be_kind_of BytePack
    expect(b.storage.first).must_equal 65280
  end

  it "can be initialized with a single int or an array of ints" do
    b = BytePack.new(int: 65535)
    expect(b).must_be_kind_of BytePack
    expect(b.storage.first).must_equal 65535

    b = BytePack.new(int: [1, 2, 3, 4])
    expect(b).must_be_kind_of BytePack
    expect(b.storage).must_equal [1, 2, 3, 4]
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
