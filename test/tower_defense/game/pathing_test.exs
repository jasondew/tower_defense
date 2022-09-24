defmodule TowerDefense.Game.PathingTest do
  use ExUnit.Case

  alias TowerDefense.Game.{Pathing, Tile}

  describe "find_path/3" do
    test "returns the shortest path from one tile to another given no barriers" do
      assert Pathing.find_path(Tile.new(0, 0), Tile.new(2, 2), [], 3) ==
               {:ok,
                [
                  Tile.new(0, 0),
                  Tile.new(1, 0),
                  Tile.new(2, 0),
                  Tile.new(2, 1),
                  Tile.new(2, 2)
                ]}
    end

    test "returns the shortest path given barriers" do
      assert Pathing.find_path(
               Tile.new(0, 0),
               Tile.new(2, 2),
               [
                 Tile.new(1, 1),
                 Tile.new(1, 2)
               ],
               3
             ) ==
               {:ok,
                [
                  Tile.new(0, 0),
                  Tile.new(1, 0),
                  Tile.new(2, 0),
                  Tile.new(2, 1),
                  Tile.new(2, 2)
                ]}
    end

    test "returns an error when there's no path" do
      assert Pathing.find_path(
               Tile.new(0, 0),
               Tile.new(2, 2),
               [
                 Tile.new(1, 0),
                 Tile.new(1, 1),
                 Tile.new(1, 2)
               ],
               3
             ) ==
               {:error, :no_path}
    end
  end
end
