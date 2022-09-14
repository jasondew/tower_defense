defmodule TowerDefense.GameTest do
  use ExUnit.Case

  alias TowerDefense.Game
  alias TowerDefense.Game.Tower

  setup do
    %{pid: start_supervised!(Game)}
  end

  describe "tick/1" do
    test "increments the timer when not paused", %{pid: pid} do
      state = Game.get_state(pid)

      Game.toggle_pause(pid)

      assert Game.tick(pid) == %{state | time: 1, paused: false}
    end

    test "no-ops when paused", %{pid: pid} do
      state = Game.get_state(pid)

      assert Game.tick(pid) == %{state | time: 0}
    end
  end

  describe "toggle_pause/1" do
    test "toggles between paused and unpaused", %{pid: pid} do
      assert %{paused: true} = Game.get_state(pid)
      assert %{paused: false} = Game.toggle_pause(pid)
    end
  end

  describe "reset/1" do
    test "resets the game state", %{pid: pid} do
      assert %{paused: false} = Game.toggle_pause(pid)
      assert %{paused: true} = Game.reset(pid)
    end
  end

  describe "set_board_disposition/2" do
    test "sets the board parameters", %{pid: pid} do
      assert %{board: %{position: %{x: 100, y: 50}, size: 780, tile_size: 30}} =
               Game.set_board_disposition(pid, %{x: 100, y: 50, size: 780})
    end
  end

  describe "place_tower/3" do
    test "adds a tower on the nearest tile", %{pid: pid} do
      Game.set_board_disposition(pid, %{x: 100, y: 50, size: 780})

      assert %{
               towers: [
                 %Tower{
                   type: :bash,
                   tile: %{x: 3, y: 7},
                   position: %{
                     top_left: %{x: 190, y: 260}
                   }
                 }
               ]
             } = Game.place_tower(pid, :bash, %{x: 195, y: 265})
    end
  end

  describe "attempt_tower_placement/3" do
    test "returns the prospective tower's position in an ok tuple", %{pid: pid} do
      Game.toggle_pause(pid)

      for x <- 50..59, y <- 50..59 do
        assert {:ok, %{x: 50, y: 50}} =
                 Game.attempt_tower_placement(pid, %{x: x, y: y})
      end
    end

    test "returns an error tuple when the game is paused", %{pid: pid} do
      assert {:error, :paused} =
               Game.attempt_tower_placement(pid, %{x: 50, y: 50})
    end

    test "returns an error tuple when out of bounds", %{pid: pid} do
      Game.toggle_pause(pid)

      assert {:error, :out_of_bounds} =
               Game.attempt_tower_placement(pid, %{x: 261, y: 261})

      assert {:error, :out_of_bounds} =
               Game.attempt_tower_placement(pid, %{x: 261, y: 260})

      assert {:error, :out_of_bounds} =
               Game.attempt_tower_placement(pid, %{x: 260, y: 261})
    end

    test "returns an error tuple when colliding with another tower", %{pid: pid} do
      Game.toggle_pause(pid)

      # this tower will occupy from (50, 50) to (69, 69)
      Game.place_tower(pid, :dart, %{x: 50, y: 50})

      for x <- 40..69, y <- 40..69 do
        assert {:error, :colliding} =
                 Game.attempt_tower_placement(pid, %{x: x, y: y})
      end
    end
  end
end
