# partially sorted binary tree
# every node has a value larger (or smaller) than that of its children
#

class Heap
  def self.children_idx(idx)
    [2 * idx + 1, 2 * idx + 2]
  end

  def self.parent_idx(idx)
    (idx - 1) / 2
  end

  def self.heapish?(parent, child, cmp_val)
    (parent <=> child) != (cmp_val * -1)
  end

  attr_reader :storage

  def initialize(cmp_val: 1, minheap: false)
    cmp_val = -1 if minheap
    case cmp_val
    when -1, 1
      @cmp_val = cmp_val
    else
      raise(ArgumentError, "unknown comparison value: #{cmp_val}")
    end
    @storage = []
  end

  def heapish_idx?(pidx, cidx)
    self.class.heapish?(@storage[pidx], @storage[cidx], @cmp_val)
  end

  def heap?(idx: 0)
    check_children = []
    self.class.children_idx(idx).each { |cidx|
      if cidx <= self.last_idx
        return false unless self.heapish_idx?(idx, cidx)
        check_children << cidx
      end
    }
    check_children.each { |cidx| return false unless self.heap?(idx: cidx) }
    true
  end

  # When you add a new node to a heap, you add it to the rightmost unoccupied
  # leaf on the lowest level. Then you upheap that node until it has reached
  # its proper position. In this way, the heap's order is maintained and the
  # heap remains a complete tree.
  def push(node)
    @storage << node
    self.sift_up(self.last_idx)
  end

  def pop
    node = @storage.shift          # remove root node
    @storage.unshift(@storage.pop) # move last node to root
    self.sift_down(0)
    node
  end

  def last_idx
    @storage.length - 1
  end

  def sift_up(idx)
    return self if idx <= 0
    parent_idx = self.class.parent_idx(idx)
    if !self.heapish_idx?(parent_idx, idx)
      # swap
      current = @storage[idx]
      @storage[idx] = @storage[parent_idx]
      @storage[parent_idx] = current
      self.sift_up(parent_idx)
    end
    self
  end

  def sift_down(idx)
    return self if idx >= @storage.length
    current = @storage[idx]
    lidx, ridx = self.class.children_idx(idx)
    # take the child most likely to be a good parent
    cidx = self.heapish_idx?(lidx, ridx) ? lidx : ridx

    if !self.heapish_idx?(idx, cidx)
      # swap
      @storage[idx] = @storage[cidx]
      @storage[cidx] = current
      self.sift_down(cidx)
    end
    self
  end
end

if __FILE__ == $0
  EYEBALL_TEST = true
  INSERT_TEST = true
  BENCHMARK_TEST = true

  if EYEBALL_TEST
    h = Heap.new
    99.times {
      r = rand 99
      puts "push #{r}"
      h.push r
      puts
    }
    p h.storage
    p h.heap?

    max = h.pop
    puts "popped #{max}"
    p h.storage
    p h.heap?
  end

  if INSERT_TEST
    count = 1
    t = Time.now
    h = Heap.new
    elapsed = 0

    while elapsed < 3
      t1 = Time.now
      h.push rand 99999
      e1 = Time.now - t1
      elapsed = Time.now - t
      count += 1
      puts "%ith insert: %0.5f s" % [count, e1] if count % 100 == 0
    end

    puts "inserted %i items in %0.1f s" % [count, elapsed]
  end

  if BENCHMARK_TEST
    require 'minitest/autorun'
    require 'minitest/benchmark'

    describe "Heap insertion Benchmark" do
      before do
        @heap = Heap.new
      end

      bench_performance_constant "insert", 0.995 do |n|
        n.times { @heap.push rand 99999 }
      end
    end
  end
end
