defmodule TowerDefense.Game.Tile do
  defstruct [:x, :y]

  @type t :: %__MODULE__{x: non_neg_integer(), y: non_neg_integer()}

  @spec new(non_neg_integer(), non_neg_integer()) :: t()
  def new(x, y), do: %__MODULE__{x: x, y: y}

  @spec from_position(
          Position.t(),
          %{x: non_neg_integer(), y: non_neg_integer()},
          pos_integer()
        ) :: t()
  def from_position(%{x: x, y: y}, offset, tile_size) do
    new(
      trunc((x - offset.x) / tile_size),
      trunc((y - offset.y) / tile_size)
    )
  end
end

defimpl Inspect, for: TowerDefense.Game.Tile do
  def inspect(%{x: x, y: y}, _opts) do
    "#(#{x}, #{y})"
  end
end
