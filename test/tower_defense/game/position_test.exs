defmodule TowerDefense.Game.PositionTest do
  use ExUnit.Case

  alias TowerDefense.Game.{Position, Tile}

  describe inspect(&Position.new/2) do
    test "returns a Position given x and y coordinates" do
      assert Position.new(3, 5) == %Position{x: 3, y: 5}
    end
  end

  describe inspect(&Position.from_tile/3) do
    test "returns the top-left Position corresponding to a Tile" do
      assert Position.from_tile(Tile.new(3, 5), %{x: 3, y: 8}, 5) == %Position{
               x: 18,
               y: 33
             }
    end

    test "returns the center Position corresponding to a Tile" do
      assert Position.from_tile(Tile.new(3, 5), %{x: 3, y: 8}, 5, :center) ==
               %Position{
                 x: 20,
                 y: 35
               }
    end

    test "returns the bottom-right Position corresponding to a Tile" do
      assert Position.from_tile(Tile.new(3, 5), %{x: 3, y: 8}, 5, :bottom_right) ==
               %Position{
                 x: 22,
                 y: 37
               }
    end
  end
end
