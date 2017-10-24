require 'compsci'

class CompSci::BinaryTree
  # integer math says idx 2 and idx 1 both have parent at idx 0
  def self.parent_idx(idx)
    (idx-1) / 2
  end

  def self.children_idx(idx)
    [2*idx + 1, 2*idx + 2]
  end

  attr_reader :store

  def initialize
    @store = []
  end

  def last_idx
    @store.length - 1
  end
end
