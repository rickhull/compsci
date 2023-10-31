require 'compsci/collatz'

include CompSci

# accept a command line argument
user_n = ARGV.empty? ? nil : ARGV.first.to_i

if user_n
  puts Collatz.loop(user_n) # run the loop down to 1
else
  iters, top = 99, 99       # 99 times, random number between 1 and 99
  reg = Collatz.register    # keep reusing a single register
  iters.times { reg = Collatz.loop(rand(top) + 1, register: reg) }
  puts Collatz.summarize reg
end
