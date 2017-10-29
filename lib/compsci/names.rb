module CompSci
  module Names
    WW1 = [:apples, :butter, :charlie, :duff, :edward, :freddy, :george,
           :harry, :ink, :johnnie, :king, :london, :monkey, :nuts, :orange,
           :pudding, :queenie, :robert, :sugar, :tommy, :uncle, :vinegar,
           :willie, :xerxes, :yellow, :zebra]
    WW2 = [:able, :baker, :charlie, :dog, :easy, :fox, :george, :how, :item,
           :jig, :king, :love, :mike, :nan, :oboe, :peter, :queen, :roger,
           :sugar, :tare, :uncle, :victor, :william, :xray, :yoke, :zebra]
    NATO = [:alfa, :bravo, :charlie, :delta, :echo, :foxtrot, :golf, :hotel,
            :india, :juliett, :kilo, :lima, :mike, :november, :oscar, :papa,
            :quebec, :romeo, :sierra, :tango, :uniform, :victor, :whiskey,
            :xray, :yankee, :zulu]
    CRYPTO = [:alice, :bob, :charlie, :david, :eve, :frank, :grace, :heidi,
              :judy, :mallory, :olivia, :peggy, :sybil, :trudy, :victor,
              :wendy]
    ENGLISH_UPPER = [*'A'..'Z']
    ENGLISH_LOWER = [*'a'..'z']

    PLANETS = [:mercury, :venus, :earth, :mars, :jupiter, :saturn, :uranus,
               :neptune, :pluto]

    SOLAR = [:mercury, :venus, :earth, :mars, :asteroid_belt, :jupiter,
             :saturn, :uranus, :neptune, :kuiper_belt, :scattered_disk,
             :heliosphere]

    # map val to [0..names.length]
    def self.assign(val, names)
      case val
      when String
        if val.match %r{\A\d+\z}
          pos = val.to_i
        else
          case names.size
          when (1..26)
            pos = val[0].upcase.ord - 'A'.ord
          when (27..99)
            pos = val[0].ord - 'A'.ord
            pos -= 6 if pos > 26
          else
            raise "unexpected names.size: #{names.size}"
          end
        end
      when Integer
        pos = val
      else
        raise "unexpected val: #{val} (#{val.class})"
      end

      if pos < 0 or pos >= names.size
        raise "val #{val} pos #{pos} outside of names range (#{names.size})"
      end
      names[pos]
    end
  end
end
