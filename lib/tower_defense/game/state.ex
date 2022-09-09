defmodule TowerDefense.Game.State do
  defstruct time: 0,
            level: 1,
            lives: 20,
            gold: 0,
            score: 0,
            paused: true,
            board: %{position: %{x: 0, y: 0}, size: 260, tile_size: 10},
            mobs: [],
            towers: []
end
