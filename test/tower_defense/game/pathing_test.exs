defmodule TowerDefense.Game.PathingTest do
  use ExUnit.Case

  alias TowerDefense.Game.{Pathing, Tile}

  describe "find_path/3" do
    test "returns the shortest path from one tile to another" do
      assert Pathing.find_path(3, Tile.new(0, 0), Tile.new(2, 2)) == [
               Tile.new(0, 0),
               Tile.new(1, 1),
               Tile.new(2, 2)
             ]
    end
  end
end
