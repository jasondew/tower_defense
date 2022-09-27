defmodule TowerDefense.Game.StateTest do
  use ExUnit.Case

  alias TowerDefense.Game
  alias TowerDefense.Game.{Creep, Position, State}

  describe "update/1" do
    test "increments the time counter" do
      assert %{time: 1} = State.update(State.new())
    end

    test "updates all creeps" do
      creep = Creep.new(:normal, Position.new(0, 0))
      state = state_with_path()

      assert %{creeps: [updated_creep]} =
               State.update(%{state | creeps: [creep]})

      refute creep == updated_creep
    end

    test "removes creeps that reach the edge and decrements the score" do
      creep = Creep.new(:normal, Position.new(250, 130))
      state = state_with_path()

      assert %{creeps: [], score: -10} =
               State.update(%{state | creeps: [creep]})
    end
  end

  defp state_with_path do
    {:ok, path} = Game.find_path([])
    %State{path: path}
  end
end
