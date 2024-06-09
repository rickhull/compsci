require 'compsci'

module CompSci
  module Elo
    INITIAL = 1500
    K = 32
    C = 400

    # rating_a and rating_b are positive numbers
    def self.expected(rating_a, rating_b)
      CompSci.positive!(rating_a) and CompSci.positive!(rating_b)
      1 / (1 + 10**((rating_b - rating_a) / C))
    end

    # outcome_a is number between 0 and 1
    # 1 indicates a "win" for A, 0 indicates a "win" for B
    # 0.5 indicates a draw, and a number like 0.6 might indicate
    # a "win" for A, like best 3 sets out of 5.
    def self.update(rating_a, rating_b, outcome_a)
      raise(ArgumentError, outcome_a.inspect) unless (0..1).include? outcome_a
      exp_a = expected(rating_a, rating_b)
      exp_b = expected(rating_b, rating_a)

      [rating_a + K * (outcome_a - exp_a),
       rating_b + K * (1 - outcome_a - exp_b)].map(&:round)
    end
  end
end
