require 'compsci/heap'

include CompSci

SPEC_TEST = true
EYEBALL_TEST = false
INSERT_TEST = true
BENCHMARK_TEST = true

if SPEC_TEST
  require 'minitest/autorun'

  describe Heap do
    it "must calculate a parent index" do
      valid = {
        1 => 0,
        2 => 0,
        3 => 1,
        4 => 1,
        5 => 2,
        6 => 2,
        7 => 3,
        8 => 3,
        9 => 4,
        10 => 4,
      }

      invalid = {
        0 => -1,
        -1 => -1,
        -2 => -2,
      }
      valid.each { |idx, pidx|
        Heap.parent_idx(idx).must_equal pidx
      }
      invalid.each { |idx, pidx|
        Heap.parent_idx(idx).must_equal pidx
      }
    end

    it "must calculate children indices" do
      valid = {
        0 => [1, 2],
        1 => [3, 4],
        2 => [5, 6],
        3 => [7, 8],
        4 => [9, 10],
        5 => [11, 12],
        6 => [13, 14],
        7 => [15, 16],
        8 => [17, 18],
        9 => [19, 20],
        10 => [21, 22],
      }

      invalid = {
        -3 => [-5, -4],
        -2 => [-3, -2],
        -1 => [-1, 0],
      }

      valid.each { |idx, cidx|
        Heap.children_idx(idx).must_equal cidx
      }
      invalid.each { |idx, cidx|
        Heap.children_idx(idx).must_equal cidx
      }
    end

    describe "instance" do
      before do
        @maxheap = Heap.new
        @minheap = Heap.new(minheap: true)
        @inserts = (1..10).to_a
        @inserts.each { |i|
          @maxheap.push i
          @minheap.push i
        }
      end

      it "must satisfy the heap property" do
        @maxheap.heap?.must_equal true
        @minheap.heap?.must_equal true
        @minheap.store.must_equal @inserts
        @maxheap.store.wont_equal @inserts
        @maxheap.store.wont_equal @inserts.reverse
      end

      it "must recognize heap violations" do
        @minheap.store.push 0
        @minheap.heap?.must_equal false
        @minheap.sift_up @minheap.last_idx
        @minheap.heap?.must_equal true

        @minheap.store.unshift 10
        @minheap.heap?.must_equal false
        @minheap.sift_down 0
        @minheap.heap?.must_equal true

        @maxheap.store.push 10
        @maxheap.heap?.must_equal false
        @maxheap.sift_up @maxheap.last_idx
        @maxheap.heap?.must_equal true

        @maxheap.store.unshift 0
        @maxheap.heap?.must_equal false
        @maxheap.sift_down 0
        @maxheap.heap?.must_equal true
      end
    end
  end
end

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
    puts "%ith insert: %0.8f s" % [count, e1] if count % 10000 == 0
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

    bench_performance_constant "insert", 0.9999 do |n|
      n.times { @heap.push rand 99999 }
    end
  end
end
