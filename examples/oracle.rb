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
        puts format("Predicted: %s Got: %s\t%s",
                    pred,
                    c,
                    c == pred ? 'CORRECT  ' : 'INCORRECT')

      end
      model.update(c)
    }
#    puts model
  end
  puts
end
