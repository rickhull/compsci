require 'compsci/oracle'
require 'pp'

include CompSci

model = Oracle::Model.new

quit = false

while !quit do
  puts "Enter characters; ctrl-c to quit"
  line = STDIN.gets.chomp
  if line.empty?
    pp model
  else
    line.each_char { |c|
      pred = model.prediction
      if pred
        puts format("Predicted: %s %.2f\tGot: %s\t%s\t%.2f%% CORRECT",
                    pred[:best_key],
                    pred[:best_pct] * 100,
                    c,
                    pred[:best_key] == c ? 'CORRECT  ' : 'INCORRECT',
                    model.correct_pct * 100)
      end
      model.update(c)
    }
    puts model
  end
  puts
end
