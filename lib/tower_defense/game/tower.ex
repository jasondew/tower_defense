defmodule TowerDefense.Game.Tower do
  defstruct [:type, :tiles, :position, :range]

  alias TowerDefense.Game.{Position, Tile}

  def new(type, top_left_tile, top_left_position, tile_size) do
    %__MODULE__{
      type: type,
      tiles: tiles_covered(top_left_tile),
      position: %{
        top_left: top_left_position,
        center: center_position(top_left_position, tile_size),
        bottom_right: bottom_right_position(top_left_position, tile_size)
      },
      range: %{
        center: center(top_left_position, tile_size),
        radius: range(type, tile_size)
      }
    }
  end

  def targeted_creep(%__MODULE__{}, _creeps = []), do: nil

  def targeted_creep(%__MODULE__{range: range}, creeps) do
    case Enum.filter(creeps, &in_range?(range, &1.position)) do
      [] -> nil
      creeps_in_range -> Enum.random(creeps_in_range)
    end
  end

  def range(_type, tile_size), do: tile_size * 3

  def damage(%__MODULE__{}) do
    # TODO: implement different damage per type
    1
  end

  def tiles_covered(%Tile{x: x, y: y}) do
    [
      Tile.new(x, y),
      Tile.new(x + 1, y),
      Tile.new(x, y + 1),
      Tile.new(x + 1, y + 1)
    ]
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

  defp center_position(%{x: x, y: y}, tile_size) do
    Position.new(x + tile_size - 1, y + tile_size - 1)
  end

  defp bottom_right_position(%{x: x, y: y}, tile_size) do
    Position.new(x + 2 * tile_size - 1, y + 2 * tile_size - 1)
  end

  defp center(%{x: x, y: y}, tile_size) do
    Position.new(x + tile_size, y + tile_size)
  end

  defp in_range?(%{center: center, radius: radius}, position) do
    (position.x - center.x) ** 2 + (position.y - center.y) ** 2 <= radius ** 2
  end
end
