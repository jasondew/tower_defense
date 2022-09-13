defmodule TowerDefense.Game.State do
  alias TowerDefense.Game.Board

  defstruct time: 0,
            level: 1,
            lives: 20,
            gold: 0,
            score: 0,
            paused: true,
            board: %Board{},
            mobs: [],
            towers: []
end
