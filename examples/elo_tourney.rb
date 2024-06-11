require 'compsci/elo'

include CompSci

# return two different integers 0..(pool.count -1)
def pool_matchup(pool)
  a = rand(pool.count)
  [a, (a + rand(pool.count - 1) + 1) % pool.count]
end

# sum / divide / round
def avg_rating(pool)
  (pool.map(&:rating).sum.to_f / pool.count).round
end

class Array
  # reverse sort
  def rank
    sort { |a, b| b <=> a }
  end
end

pool_size = 999
pool_matchups = 99_999
tourney_size = 64
iters = 5
play_7 = true

# randomize skill levels
pool = Elo::Player.init_pool(pool_size).each { |player|
  player.skill = rand.round(3)
}

# LETS GO

iters.times { |i|
  puts
  puts
  puts "=" * 40
  puts "               Season #{i + 1}"
  puts "=" * 40

  # pool matchups
  pool_matchups.times {
    a, b = pool_matchup(pool)
    pool[a].simulate(pool[b]) # win / lose / draw
  }
  pool = pool.rank
  puts "Ran #{pool_matchups} matchups; average rating: #{avg_rating(pool)}"

  # bottom 5% of pool retires
  rc = pool_size / 20
  (pool.count - rc).upto(pool.count - 1) { |i|
    pool[i] = Elo::Player.new(skill: rand.round(3))
  }
  puts "Retired the bottom 5%; average rating: #{avg_rating(pool)}"

  # take top 64 for the tournament
  puts
  puts "Top 64:"
  puts '---'
  tpool = pool.take(tourney_size).each { |p| puts p }.shuffle
  puts

  # run the tournament
  while tpool.size > 1
    puts "Players: #{tpool.size}"
    puts '---'
    next_round = []

    # evens play odds
    (tpool.size / 2).times { |i|
      a = i * 2
      b = a + 1
      puts format("%s    vs    %s", tpool[a], tpool[b])

      if play_7
        # best 4 out of 7
        wins, losses = 0, 0
        while (wins < 4 and losses < 4) or (wins == losses)
          outcome = tpool[a].simulate(tpool[b])
          if outcome == 0.5
            wins += 0.5
            losses += 0.5
          elsif outcome < 0.5
            losses += 1
          else
            wins += 1
          end
        end
        if wins > losses
          outcome, winner = 1, tpool[a]
        else
          outcome, winner = 0, tpool[b]
        end
      else
        outcome = tpool[a].simulate(tpool[b], type: :rand)
        winner = tpool[outcome >= 0.5 ? a : b]
      end
      next_round << winner
      puts "Outcome: #{outcome}\tWinner: #{winner}"
      puts
    }
    puts
    tpool = next_round
  end

  # a few pros retire
  retired = Set.new
  3.times { retired.add(rand(tourney_size)) }
  puts "Retired: #{retired.sort.join(', ')}"
  retired.each { |i|
    print pool[i]
    pool[i] = Elo::Player.new(skill: rand.round(3))
    puts "  ->  #{pool[i]}"
  }
  puts

  # 5% non-pros retire
  retired = Set.new
  (pool_size / 20).times {
    retired.add(rand(pool_size - tourney_size) + tourney_size)
  }
  puts "Retired: #{retired.sort.join(', ')}"
  retired.each { |i|
    pool[i] = Elo::Player.new(skill: rand.round(3))
  }

  pool = pool.rank
  puts "Average rating: #{avg_rating(pool)}"
  puts
}

# pool matchups
pool_matchups.times {
  a, b = pool_matchup(pool)
  pool[a].simulate(pool[b]) # win / lose / draw
}
pool = pool.rank
puts "Ran #{pool_matchups} matchups; average rating: #{avg_rating(pool)}"

puts pool
