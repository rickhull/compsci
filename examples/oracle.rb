require 'compsci/oracle'
require 'pp'

include CompSci

model = Oracle::Model.new(3)

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
        puts model
        puts format("Predicted: %s %.2f\tGot: %s\t%s",
                    pred[:best_key],
                    pred[:best_pct] * 100,
                    c,
                    pred[:best_key] == c ? 'CORRECT  ' : 'INCORRECT')

      end
      model.update(c)
    }
#    puts model
  end
  puts
end
