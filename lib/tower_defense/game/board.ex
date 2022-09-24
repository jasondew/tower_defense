defmodule TowerDefense.Game.Board do
  defstruct position: %{
              top_left: %{x: 0, y: 0},
              bottom_right: %{x: 259, y: 259}
            },
            tile_size: 10
end
