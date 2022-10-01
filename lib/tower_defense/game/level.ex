defmodule TowerDefense.Game.Level do
  alias TowerDefense.Game.Creep

  def creeps(_level, starting_position) do
    # TODO: vary per level
    for _ <- 1..10 do
      [Creep.new(:normal, starting_position)]
    end
  end
end
