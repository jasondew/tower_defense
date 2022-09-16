defmodule TowerDefense.Game.Tower do
  defstruct [:type, :tile, :position, :range]

  def new(type, tile, top_left_position, tile_size) do
    %__MODULE__{
      type: type,
      tile: tile,
      position: %{
        top_left: top_left_position,
        bottom_right: bottom_right_position(top_left_position, tile_size)
      },
      range: %{
        center: center(top_left_position, tile_size),
        radius: radius(type, tile_size)
      }
    }
  end

  def inside?(
        %__MODULE__{
          position: %{top_left: top_left, bottom_right: bottom_right}
        },
        position
      ) do
    top_left.x <= position.x && position.x <= bottom_right.x &&
      top_left.y <= position.y && position.y <= bottom_right.y
  end

  ## PRIVATE FUNCTIONS

  defp bottom_right_position(%{x: x, y: y}, tile_size) do
    %{x: x + 2 * tile_size - 1, y: y + 2 * tile_size - 1}
  end

  defp center(%{x: x, y: y}, tile_size) do
    %{x: x + tile_size, y: y + tile_size}
  end

  # TODO: this should be dynamic based on the tower type
  defp radius(_type, tile_size), do: tile_size * 2
end
