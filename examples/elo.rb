require 'compsci/elo'

include CompSci

def avg_rating(players)
  (players.map(&:rating).sum.to_f / players.count).round
end

# return two different indices, 0..players.count
def matchup(players)
  a = rand(players.count)
  [a, (a + rand(players.count - 1) + 1) % players.count]
end

def retire(players)
  retired = Set.new

  # take 1 from the top 10 or 20
  if rand(3) % 2 == 1
    retired.add rand(10)
  else
    retired.add rand(10) + 10
  end
  # take the bottom 4
  (players.count - 4).upto(players.count - 1) { |i| retired.add i }
  # 5 others randomly outside the top 10 and bottom 5
  5.times { retired.add rand(players.count - 14) + 10 }

  retired.each { |i|
    players[i] = Elo::Player.new(elo: ELO, skill: rand.round(3))
  }
  retired.sort
end

ELO = Elo.new(initial: 1500)

num_players = 99
num_matches = 9999
retirement_periods = 3
offset = 7

players = Elo::Player.init_pool(num_players, elo: ELO).each { |p|
  p.skill = rand.round(3)
}

class Array
  def rank
    sort { |a, b| b <=> a }
  end
end

puts
puts "#{num_matches} matches without retirement"
puts

num_matches.times { |i|
  a, b = matchup(players)
  players[a].simulate players[b]
}

puts players = players.rank
puts
puts "Avg Rating: #{avg_rating(players)}"
puts

########

puts "#{num_matches} matches with #{retirement_periods}x 10% retirement"
puts

num_matches.times { |i|
  a, b = matchup(players)
  players[a].simulate players[b]
  if i % (num_matches / retirement_periods) == num_matches / offset
    players = players.rank
    puts format("Played %i matches, retired %s", i, retire(players).join(', '))
  end
}
puts

puts players = players.rank
puts
puts "Avg Rating: #{avg_rating(players)}"
puts

#########

puts "Now idx 0 is a shark, with retirement"
puts

num_matches.times { |i|
  a, b = matchup(players)
  if a == 0 or b == 0
    players[a].update(players[b], a == 0 ? 1 : 0)  # idx 0 always wins
  else
    players[a].simulate(players[b])
  end
  if i % (num_matches / retirement_periods) == num_matches / offset
    puts format("Played %i matches, retired %s", i, retire(players).join(', '))
  end
}
puts

puts players = players.rank
puts
puts "Avg Rating: #{avg_rating(players)}"
puts
