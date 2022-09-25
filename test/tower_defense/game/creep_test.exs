defmodule TowerDefense.Game.CreepTest do
  use ExUnit.Case

  alias TowerDefense.Game
  alias TowerDefense.Game.{Creep, Position, State}

  describe "new/3" do
    test "returns a new Creep struct" do
      assert %Creep{type: :normal, health: 10, position: %{x: 10, y: 20}} =
               Creep.new(:normal, Position.new(10, 20))
    end
  end

  describe "update/2" do
    test "moves the Creep along the path by one unit of speed" do
      assert %Creep{position: %{x: 10, y: 130}} =
               Creep.new(:normal, Position.new(0, 130), 10)
               |> Creep.update(state_with_path())
    end

    test "moves the Creep back towards the path if it's off of it" do
      assert %Creep{position: %{x: 0, y: 10}} =
               Creep.new(:normal, Position.new(0, 0), 10)
               |> Creep.update(state_with_path())
    end

    test "continues moving on the same heading if not crossing a tile boundary" do
      assert %Creep{speed: 5, position: %{x: 5, y: 130}} =
               Creep.new(:normal, Position.new(0, 130), 5)
               |> Creep.update(state_with_path())
    end

    test "continues moving after entering the destination tile" do
      assert %Creep{position: %{x: 260, y: 130}} =
               Creep.new(:normal, Position.new(250, 130), 10)
               |> Creep.update(state_with_path())
    end
  end

  defp state_with_path do
    {:ok, path} = Game.find_path([])
    %State{path: path}
  end
end
