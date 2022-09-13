defmodule TowerDefense.Game.Board do
  defstruct position: %{x: 0, y: 0},
            size: 260,
            tile_size: 10

  @spec tile_and_position(%{x: non_neg_integer(), y: non_neg_integer()}, map()) ::
          %{
            tile: %{x: non_neg_integer(), y: non_neg_integer()},
            position: %{x: non_neg_integer(), y: non_neg_integer()}
          }
  def tile_and_position(position, board) do
    tile_x = tile(position.x, board.position.x, board.tile_size)
    tile_y = tile(position.y, board.position.y, board.tile_size)

    %{
      tile: %{x: tile_x, y: tile_y},
      position: %{
        x: tile_x * board.tile_size + board.position.x,
        y: tile_y * board.tile_size + board.position.y
      }
    }
  end

  ## PRIVATE FUNCTIONS

  defp tile(coordinate, offset, tile_size) do
    trunc((coordinate - offset) / tile_size)
  end
end
