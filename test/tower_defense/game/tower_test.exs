defmodule TowerDefense.Game.TowerTest do
  use ExUnit.Case

  alias TowerDefense.Game.{Creep, Position, Tile, Tower}

  describe "new/3" do
    test "returns a Tower struct" do
      assert %Tower{
               type: :bash,
               tiles: [
                 %Tile{x: 3, y: 7},
                 %Tile{x: 4, y: 7},
                 %Tile{x: 3, y: 8},
                 %Tile{x: 4, y: 8}
               ],
               position: %{
                 top_left: %Position{x: 50, y: 70},
                 bottom_right: %Position{x: 69, y: 89}
               },
               range: %{
                 center: %Position{x: 60, y: 80},
                 radius: 30
               }
             } = Tower.new(:bash, Tile.new(3, 7), Position.new(50, 70), 10)
    end
  end

  describe "targeted_creep/2" do
    test "returns nil given no creeps" do
      refute Tower.targeted_creep(
               Tower.new(:squirt, Tile.new(3, 7), Position.new(50, 70), 10),
               []
             )
    end

    test "returns nil when no creeps in range" do
      refute Tower.targeted_creep(
               Tower.new(:squirt, Tile.new(3, 7), Position.new(50, 70), 10),
               [Creep.new(:normal, Position.new(0, 0))]
             )
    end

    test "returns a random creep in range" do
      in_range_creep = Creep.new(:normal, Position.new(40, 60))
      out_of_range_creep = Creep.new(:normal, Position.new(20, 70))

      assert Tower.targeted_creep(
               Tower.new(:squirt, Tile.new(3, 7), Position.new(50, 70), 10),
               [in_range_creep, out_of_range_creep]
             ) == in_range_creep
    end
  end

  describe "tiles_covered/1" do
    test "returns the list of tiles covered by a tower at the given tile" do
      assert Tower.tiles_covered(Tile.new(1, 1)) == [
               Tile.new(1, 1),
               Tile.new(2, 1),
               Tile.new(1, 2),
               Tile.new(2, 2)
             ]
    end
  end

  describe "inside?/2" do
    test "returns true when the position is inside of the tower" do
      tower = Tower.new(:squirt, %Tile{x: 0, y: 0}, %{x: 50, y: 50}, 10)

      for x <- 50..69, y <- 50..69 do
        assert Tower.inside?(tower, %{x: x, y: y})
      end
    end

    test "returns false when the position is outside of the tower" do
      refute Tower.inside?(
               Tower.new(:squirt, Tile.new(0, 0), %{x: 50, y: 50}, 10),
               %{x: 70, y: 70}
             )
    end
  end
end
