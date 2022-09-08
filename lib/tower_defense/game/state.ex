defmodule TowerDefense.Game.State do
  defstruct time: 0,
            level: 1,
            lives: 20,
            gold: 0,
            score: 0,
            paused: true,
            mobs: [],
            towers: []
end
