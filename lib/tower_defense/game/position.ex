defmodule TowerDefense.Game.Position do
  defstruct [:x, :y]

  alias TowerDefense.Game.Tile

  @type t :: %__MODULE__{x: non_neg_integer(), y: non_neg_integer()}

  @spec new(non_neg_integer(), non_neg_integer()) :: t()
  def new(x, y), do: %__MODULE__{x: x, y: y}

  @spec from_tile(
          Tile.t(),
          %{x: non_neg_integer(), y: non_neg_integer()},
          pos_integer(),
          :top_left | :bottom_right | :center
        ) :: t()
  def from_tile(_tile, _offset, _tile_size, which_point \\ :top_left)

  def from_tile(tile, offset, tile_size, :top_left) do
    new(
      tile.x * tile_size + offset.x,
      tile.y * tile_size + offset.y
    )
  end

  def from_tile(tile, offset, tile_size, :center) do
    new(
      tile.x * tile_size + offset.x + trunc(tile_size / 2),
      tile.y * tile_size + offset.y + trunc(tile_size / 2)
    )
  end

  def from_tile(tile, offset, tile_size, :bottom_right) do
    new(
      tile.x * tile_size + offset.x + trunc(tile_size) - 1,
      tile.y * tile_size + offset.y + trunc(tile_size) - 1
    )
  end
end

defimpl Inspect, for: TowerDefense.Game.Position do
  def inspect(%{x: x, y: y}, _opts) do
    "(#{x}, #{y})"
  end
end
