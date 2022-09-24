defmodule TowerDefense.Game.StateTest do
  use ExUnit.Case

  alias TowerDefense.Game.{Creep, Position, State}

  describe "update/1" do
    test "increments the time counter" do
      assert %{time: 1} = State.update(State.new())
    end

    test "updates all creeps" do
      assert %{creeps: [%Creep{position: %{x: 10, y: 0}}]} =
               State.update(%State{
                 creeps: [
                   Creep.new(:normal, Position.new(0, 0), Position.new(100, 0))
                 ]
               })
    end

    test "removes creeps that reach the edge and decrements the score" do
      assert %{creeps: [], score: -10} =
               State.update(%State{
                 creeps: [
                   Creep.new(
                     :normal,
                     Position.new(770, 0),
                     Position.new(770, 0)
                   )
                 ]
               })
    end
  end
end
