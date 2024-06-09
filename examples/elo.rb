require 'compsci/elo'

include CompSci

def outcome(type = :default)
  case type
  when :default       # win=1  lose=0   draw=0.5
    d100 = rand(100)
    case d100
    when 0, 1
      0.5 # draw
    else
      d100 % 2 == 0 ? 1 : 0
    end
  when :rand          # any float 0..1
    rand
  when :no_draw       # win=1  lose=0
    rand(2) == 0 ? 1 : 0
  else
    raise "unexpected type: #{type.inspect}"
  end
end

include_retirement = true
num_players = 99
num_matches = 9999
elo = Elo.new
players = Elo::Player.init_pool(num_players, elo)

num_matches.times { |i|
  a, b = rand(num_players), rand(num_players)
  b = (a + 1) % num_players if a == b
  players[a].update(players[b], outcome())

  if include_retirement and i % 500 == 0
    # 10% of players retire and are replaced by newbies
    (num_players / 10).times {
      players[rand(num_players)].rating = elo.initial
    }
  end
}

avg = players.map(&:rating).sum.to_f / num_players

p players.map(&:rating)
puts
puts "Avg Rating: #{avg.round}"

# now introduce a shark
puts
puts "Now idx 0 is a shark"
puts

num_matches.times { |i|
  a, b = rand(num_players), rand(num_players)
  b = (a + 1) % num_players if a == b
  if a == 0 or b == 0
    outcome = a == 0 ? 1 : 0  # idx 0 always wins
  else
    outcome = outcome()
  end
  players[a].update(players[b], outcome)
}

avg = players.map(&:rating).sum.to_f / num_players

p players.map(&:rating)
puts
puts "Avg Rating: #{avg.round}"
