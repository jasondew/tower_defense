defmodule TowerDefense.GameTest do
  use ExUnit.Case

  alias TowerDefense.Game

  describe "tick/0" do
    test "increments the timer" do
      pid = start_supervised!(Game)
      initial_state = Game.get_state(pid)

      assert Game.tick(pid) == %{initial_state | time: 1}
    end
  end
end
