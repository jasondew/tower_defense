defmodule TowerDefense.Game.CreepTest do
  use ExUnit.Case

  alias TowerDefense.Game
  alias TowerDefense.Game.{Creep, Position, State}

  describe "new/3" do
    test "returns a new Creep struct" do
      assert %Creep{
               species: :normal,
               health: 20,
               maximum_health: 20,
               position: %{x: 10, y: 20}
             } = Creep.new(:normal, Position.new(10, 20))
    end
  end

  describe "update/2" do
    test "moves the Creep along the path by one unit of speed" do
      assert %Creep{position: %{x: 10, y: 130}} =
               Creep.new(:normal, Position.new(0, 130), speed: 1.0)
               |> Creep.update(state_with_path())
    end

    test "moves the Creep back towards the path if it's off of it" do
      assert %Creep{position: %{x: 0, y: 10}} =
               Creep.new(:normal, Position.new(0, 0), speed: 1.0)
               |> Creep.update(state_with_path())
    end

    test "continues moving on the same heading if not crossing a tile centerpoint" do
      assert %Creep{speed: 0.5, position: %{x: 5, y: 130}} =
               Creep.new(:normal, Position.new(0, 130), speed: 0.5)
               |> Creep.update(state_with_path())
    end

    test "continues moving on the same heading upon crossing the destination tile's centerpoint" do
      assert %Creep{position: %{x: 255, y: 130}} =
               Creep.new(:normal, Position.new(245, 130), speed: 1.0)
               |> Creep.update(state_with_path())
    end

    test "returns nil if the Creep has moved off the board" do
      refute Creep.new(:normal, Position.new(250, 130), speed: 1.0)
             |> Creep.update(state_with_path())
    end

    test "allows overriding health" do
      assert %Creep{health: 40, maximum_health: 40} =
               Creep.new(:normal, Position.new(245, 130), health: 40)
    end
  end

  defp state_with_path do
    {:ok, path} = Game.find_path([])
    %State{path: path}
  end
end
