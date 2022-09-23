defmodule TowerDefense.Game.Tile do
  defstruct [:x, :y]

  def new(x, y), do: %__MODULE__{x: x, y: y}
end
