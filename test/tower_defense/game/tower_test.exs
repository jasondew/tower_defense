defmodule TowerDefense.Game.TowerTest do
  use ExUnit.Case

  alias TowerDefense.Game.Tower

  describe "new/3" do
    test "returns a Tower struct" do
      assert %Tower{
               type: :bash,
               tile: %{x: 3, y: 7},
               position: %{
                 top_left: %{x: 50, y: 70},
                 bottom_right: %{x: 69, y: 89}
               },
               range: %{
                 center: %{x: 60, y: 80},
                 radius: 20
               }
             } = Tower.new(:bash, %{x: 3, y: 7}, %{x: 50, y: 70}, 10)
    end
  end

  describe "inside?/2" do
    test "returns true when the position is inside of the tower" do
      tower = Tower.new(:squirt, %{x: 0, y: 0}, %{x: 50, y: 50}, 10)

      for x <- 50..69, y <- 50..69 do
        assert Tower.inside?(tower, %{x: x, y: y})
      end
    end

    test "returns false when the position is outside of the tower" do
      refute Tower.inside?(
               Tower.new(:squirt, %{x: 0, y: 0}, %{x: 50, y: 50}, 10),
               %{x: 70, y: 70}
             )
    end
  end
end
