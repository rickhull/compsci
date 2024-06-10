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
  elo = players[0].elo
  (players.count / 10).times {
    i = rand(players.count - 1) + 1  # don't retire idx 0
    players[i] = Elo::Player.new(elo, skill: rand.round(3))
    retired.add i
  }
  retired.sort
end

num_players = 99
num_matches = 9999
elo = Elo.new(initial: 1500)
players = Elo::Player.init_pool(num_players, elo).each { |p|
  p.skill = rand.round(3)
}

puts
puts "#{num_matches} matches without retirement"
puts

num_matches.times { |i|
  a, b = matchup(players)
  players[a].simulate players[b]
}

players.each { |p| puts p }
puts
puts "Avg Rating: #{avg_rating(players)}"
puts

########

puts "#{num_matches} matches with 10x 10% retirement"
puts

num_matches.times { |i|
  a, b = matchup(players)
  players[a].simulate players[b]
  if i % (num_matches / 10) == num_matches / 15
    puts format("Played %i matches, retired %s", i, retire(players).join(', '))
  end
}
puts

players.each { |p| puts p }
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
  if i % (num_matches / 10) == num_matches / 15
    puts format("Played %i matches, retired %s", i, retire(players).join(', '))
  end
}
puts

players.each { |p| puts p }
puts
puts "Avg Rating: #{avg_rating(players)}"
puts

puts "SORTED:"
players.sort_by { |p| -1 * p.rating }.each { |p| puts p }
puts
