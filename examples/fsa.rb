require 'compsci/fsa'

include CompSci

puts FiniteStateAutomaton.turnstile
puts
puts
puts FiniteStateAutomaton.cauchy
puts
puts

#transitions = 999_999
#letters = 999
#numbers = 9999

transitions = 2799
letters = 62
numbers = 999

puts "A large FSA:"
puts format("%.1fk transitions between %.1fk states",
            transitions.to_f / 1000, numbers.to_f / 1000)
puts "generating..."

def letter(n)
  if n >= 52
    (n - 52).to_s # the letter is a numeric string
  else
    (65 + n + (n >= 26 ? 6 : 0)).chr # upper or lowercase alpha
  end
end

fsa = FSA.new(0)
transitions.times {
  fsa.chain_state(letter(rand(letters)), rand(numbers))
}
puts "DONE"

puts "p to print; w to walk; s to scan; N to walk N transitions; q to quit"

input = gets.chomp.downcase

case input
when 'p'
  puts fsa
when 'w'
  puts "walking #{letters} transitions..."
  puts "START: #{fsa.cursor.value}"
  letters.times {
    t = fsa.next
    puts "--#{t}--> #{fsa.cursor.value}"
  }
  puts "DONE: #{fsa.cursor.value}"
when 's'
  puts "scanning..."
  fsa.scan
  puts "DONE"
when 'q'
  # ok
when /\d+/
  input.to_i.times { fsa.next :sample }
  puts "DONE: #{fsa.cursor.value}"
else
  # ok
end

#inputs = {
#  mon: 2,
#  tues: 3,
#  thurs: 5,
#  tye: 99,
#}

# insert keys, lexicographically sorted

# insert mon: 2
# ((0)) m/2 (1) o (2) n ((3))

# insert thurs: 5 (thurs < tues lexicographically)
# freeze mon, it will never be updated

#      m/2 (1) o (2) n
# ((0))                            ((3))
#      t/5 (4) h (5) u (6) r (7) s

# note, we can't freeze thursday yet.  and it may mate up with ((3))

# insert tues: 3

#
#      m/2 (1) o (2) n
# ((0))
#      t/5     h (5) u (6) r (7) s   ((3))
#          (4)
#              u (8) e (9) s

# t/5 is too large for {tues: 3}.  minimize t to 3. add 2 to h
#      t/3     h/2 u r s
#              u   e s
#

# algorithm for adjusting weights:
#   when a new input creates a conflict
#     (there is a common prefix, and the new input's weight < last common edge)
#     set the last common edge's weight to the input weight
#     add the difference to every other downstream neighbor's weight

# now we can freeze 'hurs', since every further insertion is after 'tues'


#
#          (1)  o  (2) n
#      m/2
# ((0))
#      t/3     h/2 (5) u (6) r (7) s   ((3))
#          (4)
#               u  (8) e (9) s



# how can we combine suffixes?

# on a new word:
# 1. split into (common prefix, current suffix)
# 2. find the last state of the common prefix
# 3. does lastState have existing children?
# 3a. Yes: call replace_or_register (this operates on the prior added word)
#          add currentSuffix to lastState
# 3b. No:  add currentSuffix to lastState


# replace_or_register(state)
# 1. find the "last" child of this state
#    follow the edge with the highest lex value
# 2. if the last child has children: replace_or_register(last child)
# 3. now, via recursion, we are at the last state of the previously added word
# 4. as the recursion stack unwinds, check the register for the current state
# 5. if the register has an equivalent for the current state
# 5a. yes: replace the current state with that from the register
# 5b. no:  place the current state in the register
