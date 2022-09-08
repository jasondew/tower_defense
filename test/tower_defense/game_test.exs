defmodule TowerDefense.GameTest do
  use ExUnit.Case

  alias TowerDefense.Game

  describe "tick/1" do
    test "increments the timer when not paused" do
      pid = start_supervised!(Game)
      state = Game.get_state(pid)

      Game.toggle_pause(pid)

      assert Game.tick(pid) == %{state | time: 1, paused: false}
    end

    test "no-ops when paused" do
      pid = start_supervised!(Game)
      state = Game.get_state(pid)

      assert Game.tick(pid) == %{state | time: 0}
    end
  end

  describe "toggle_pause/1" do
    test "toggles between paused and unpaused" do
      pid = start_supervised!(Game)

      assert %{paused: true} = Game.get_state(pid)
      assert %{paused: false} = Game.toggle_pause(pid)
    end
  end

  describe "reset/1" do
    test "resets the game state" do
      pid = start_supervised!(Game)

      assert %{paused: false} = Game.toggle_pause(pid)
      assert %{paused: true} = Game.reset(pid)
    end
  end

  describe "add_tower/3" do
    test "adds a tower to the state" do
      pid = start_supervised!(Game)

      assert %{towers: []} = Game.get_state(pid)
      assert %{towers: [%{position: {5, 5}, type: :bash}]} = Game.add_tower(pid, :bash, {5, 5})
    end
  end
end
