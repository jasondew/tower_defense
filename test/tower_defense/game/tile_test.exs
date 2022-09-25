defmodule TowerDefense.Game.TileTest do
  use ExUnit.Case

  alias TowerDefense.Game.{Position, Tile}

  describe "new/2" do
    test "returns a Tile at the given coordinates" do
      assert Tile.new(3, 5) == %Tile{x: 3, y: 5}
    end
  end

  describe "from_position/3" do
    test "returns a Tile covering the given position" do
      assert Tile.from_position(Position.new(25, 39), Position.new(3, 7), 5) ==
               %Tile{
                 x: 4,
                 y: 6
               }
    end
  end
end
