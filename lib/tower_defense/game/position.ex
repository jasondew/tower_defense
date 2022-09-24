defmodule TowerDefense.Game.Position do
  defstruct [:x, :y]

  alias TowerDefense.Game.Tile

  @type t :: %__MODULE__{x: non_neg_integer(), y: non_neg_integer()}

  @spec new(non_neg_integer(), non_neg_integer()) :: t()
  def new(x, y), do: %__MODULE__{x: x, y: y}

  @spec from_tile(
          Tile.t(),
          %{x: non_neg_integer(), y: non_neg_integer()},
          pos_integer()
        ) :: t()
  def from_tile(tile, offset, tile_size) do
    new(
      tile.x * tile_size + offset.x,
      tile.y * tile_size + offset.y
    )
  end
end

defimpl Inspect, for: TowerDefense.Game.Position do
  def inspect(%{x: x, y: y}, _opts) do
    "(#{x}, #{y})"
  end
end
