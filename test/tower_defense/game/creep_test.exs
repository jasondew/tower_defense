defmodule TowerDefense.Game.CreepTest do
  use ExUnit.Case

  alias TowerDefense.Game.{Creep, Position}

  describe "new/3" do
    test "returns a new Creep struct" do
      assert %Creep{type: :normal, health: 10, position: %{x: 10, y: 20}} =
               Creep.new(:normal, Position.new(10, 20), Position.new(30, 20))
    end
  end

  describe "update/2" do
    @tag skip: true
    test "moves the Creep along it's path by one unit of speed" do
      assert %Creep{speed: 10, position: %{x: 10, y: 0}} =
               Creep.new(:normal, Position.new(0, 0), Position.new(30, 0))
    end
  end
end
