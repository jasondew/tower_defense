defmodule TowerDefense.Game.PriorityQueueTest do
  use ExUnit.Case

  alias TowerDefense.Game.PriorityQueue

  describe "public API" do
    test "stores elements and returns them in prioritized order" do
      priority_queue = PriorityQueue.new()
      priority_queue = PriorityQueue.put(priority_queue, 0, :foo)
      priority_queue = PriorityQueue.put(priority_queue, 1, :bar)
      priority_queue = PriorityQueue.put(priority_queue, 0, :baz)
      priority_queue = PriorityQueue.put(priority_queue, 10, :quux)

      assert {:baz, priority_queue} = PriorityQueue.get(priority_queue)
      assert {:foo, priority_queue} = PriorityQueue.get(priority_queue)
      assert {:bar, priority_queue} = PriorityQueue.get(priority_queue)

      priority_queue = PriorityQueue.put(priority_queue, 0, :qux)

      assert {:qux, priority_queue} = PriorityQueue.get(priority_queue)
      assert {:quux, priority_queue} = PriorityQueue.get(priority_queue)
      refute PriorityQueue.get(priority_queue)
    end
  end
end
