defmodule TowerDefense.Game.CreepTest do
  use ExUnit.Case

  alias TowerDefense.Game.Creep

  describe "new/2" do
    test "returns a new creep struct" do
      assert %Creep{type: :normal, health: 10, position: %{x: 10, y: 20}} =
               Creep.new(:normal, %{x: 10, y: 20})
    end
  end

  describe "update/2" do
    test "moves the creep along it's path by one unit of speed" do
      assert %Creep{position: %{x: 10, y: 0}} =
               Creep.update(Creep.new(:normal, %{x: 0, y: 0}))
    end
  end
end
