defmodule TowerDefense.Game.Tower do
  defstruct [:model, :tiles, :position, :radius]

  alias TowerDefense.Game.{Position, Tile}

  @type model :: :pellet | :squirt | :dart | :swarm | :frost | :bash
  @type t :: %__MODULE__{
          model: model,
          tiles: [Tile.t()],
          position: %{
            top_left: Position.t(),
            center: Position.t(),
            bottom_right: Position.t()
          },
          radius: pos_integer()
        }

  @spec models :: [model]
  def models, do: ~w[pellet squirt dart swarm frost bash]a

  @spec new(model, Position.t(), Position.t(), pos_integer()) :: t()
  def new(model, top_left_tile, top_left_position, tile_size) do
    %__MODULE__{
      model: model,
      tiles: tiles_covered(top_left_tile),
      position: %{
        top_left: top_left_position,
        center: center_position(top_left_position, tile_size),
        bottom_right: bottom_right_position(top_left_position, tile_size)
      },
      radius: round(radius(model) * tile_size)
    }
  end

  @spec targeted_creep(t(), [Creep.t()]) :: Creep.t() | nil
  def targeted_creep(%__MODULE__{}, _creeps = []), do: nil

  def targeted_creep(%__MODULE__{} = tower, creeps) do
    case Enum.filter(creeps, &in_range?(tower, &1.position)) do
      [] -> nil
      creeps_in_range -> Enum.random(creeps_in_range)
    end
  end

  def radius(:pellet), do: 4
  def radius(:squirt), do: 5
  def radius(:dart), do: 6
  def radius(:swarm), do: 4
  def radius(:frost), do: 3
  def radius(:bash), do: 3

  def damage(%__MODULE__{model: :pellet}), do: 10
  def damage(%__MODULE__{model: :squirt}), do: 5
  def damage(%__MODULE__{model: :dart}), do: 8
  def damage(%__MODULE__{model: :swarm}), do: 20
  def damage(%__MODULE__{model: :frost}), do: 10
  def damage(%__MODULE__{model: :bash}), do: 10

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

  defp in_range?(%{position: %{center: center}, radius: radius}, position) do
    (position.x - center.x) ** 2 + (position.y - center.y) ** 2 <= radius ** 2
  end
end
