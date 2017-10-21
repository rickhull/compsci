# partially sorted binary tree
# every node has a value larger (or smaller) than that of its children
#

class Heap
  def self.parent_idx(idx)
    (idx-1) / 2
  end

  def self.children_idx(idx)
    [2*idx + 1, 2*idx + 2]
  end

  attr_reader :store

  def initialize(cmp_val: 1, minheap: false)
    cmp_val = -1 if minheap
    case cmp_val
    when -1, 1
      @cmp_val = cmp_val
    else
      raise(ArgumentError, "unknown comparison value: #{cmp_val}")
    end
    @store = []
  end

  def push(node)
    @store << node
    self.sift_up(self.last_idx)
  end

  def pop
    node = @store.shift        # remove root node
    @store.unshift(@store.pop) # move last node to root
    self.sift_down(0)
    node
  end

  def sift_up(idx)
    return self if idx <= 0
    pidx = self.class.parent_idx(idx)
    if !self.heapish?(pidx, idx)
      @store[idx], @store[pidx] = @store[pidx], @store[idx] # swap
      self.sift_up(pidx)
    end
    self
  end

  def sift_down(idx)
    return self if idx > self.last_idx
    lidx, ridx = self.class.children_idx(idx)
    # take the child most likely to be a good parent
    cidx = self.heapish?(lidx, ridx) ? lidx : ridx
    if !self.heapish?(idx, cidx)
      @store[idx], @store[cidx] = @store[cidx], @store[idx] # swap
      self.sift_down(cidx)
    end
    self
  end

  def heapish?(pidx, cidx)
    (@store[pidx] <=> @store[cidx]) != (@cmp_val * -1)
  end

  def last_idx
    @store.length - 1
  end

  def heap?(idx: 0)
    check_children = []
    self.class.children_idx(idx).each { |cidx|
      if cidx <= self.last_idx
        return false unless self.heapish?(idx, cidx)
        check_children << cidx
      end
    }
    check_children.each { |cidx| return false unless self.heap?(idx: cidx) }
    true
  end
end

if __FILE__ == $0
  EYEBALL_TEST = true
  INSERT_TEST = true
  BENCHMARK_TEST = true

  if EYEBALL_TEST
    h = Heap.new
    99.times {
      h.push rand 99
    }
    p h.store
    p h.heap?
    puts
    max = h.pop
    puts "popped #{max}"
    p h.store
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
      puts "%ith insert: %0.5f s" % [count, e1] if count % 10000 == 0
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
