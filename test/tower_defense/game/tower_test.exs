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
end
