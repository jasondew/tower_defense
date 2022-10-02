defmodule TowerDefense.Game.Creep do
  defstruct [
    :id,
    :species,
    :heading,
    :health,
    :maximum_health,
    :position,
    # must be 1 / n where n is an integer < 1
    :speed
  ]

  alias TowerDefense.Game.{Position, State, Tile}

  @type species :: :normal | :boss
  @type t :: %__MODULE__{
          id: String.t(),
          species: :normal | :immune | :spawn | :flying | :boss,
          heading: :north | :south | :east | :west,
          health: pos_integer(),
          maximum_health: pos_integer(),
          position: Position.t(),
          speed: float()
        }

  @spec species :: species
  def species, do: ~w[normal immune spawn flying boss]a

  @spec new(species, Position.t(), keyword()) :: t()
  def new(species, position, overrides \\ []) do
    health = Keyword.get(overrides, :health, health(species))
    speed = Keyword.get(overrides, :speed, speed(species))

    %__MODULE__{
      id: UUID.uuid4(),
      species: species,
      position: position,
      heading: :east,
      health: health,
      maximum_health: health,
      speed: speed
    }
  end

  @spec health(species) :: pos_integer()
  def health(:normal), do: 20
  def health(:immune), do: 73
  def health(:spawn), do: 132
  def health(:flying), do: 44
  def health(:boss), do: 500

  @spec speed(species) :: float()
  def speed(:normal), do: 1.0
  def speed(:immune), do: 1.0
  def speed(:spawn), do: 1.0
  def speed(:flying), do: 1.0
  def speed(:boss), do: 0.5

  @spec update(t(), State.t()) :: t()
  def update(creep, %{path: []}), do: creep

  def update(
        %__MODULE__{position: position, heading: heading, speed: speed} = creep,
        %{
          path: path,
          board: %{position: %{top_left: offset}, tile_size: tile_size}
        }
      ) do
    current_tile = Tile.from_position(creep.position, offset, tile_size)

    next_tile =
      case Enum.find_index(path, &(&1 == current_tile)) do
        nil ->
          # TODO: need to generate specific paths to get them back on track
          List.first(path)

        current_index ->
          Enum.at(path, current_index + 1)
      end

    if next_tile do
      amount = round(tile_size * speed)

      new_heading =
        cond do
          Tile.from_position(
            move(position, heading, amount),
            offset,
            tile_size
          ) == current_tile ->
            heading

          current_tile == next_tile ->
            heading

          next_tile.x > current_tile.x ->
            :east

          next_tile.x < current_tile.x ->
            :west

          next_tile.y > current_tile.y ->
            :south

          true ->
            :north
        end

      new_position = move(position, new_heading, amount)

      creep
      |> Map.put(:position, new_position)
      |> Map.put(:heading, new_heading)
    else
      # return nil since we've moved off the board
    end
  end

  ## PRIVATE FUNCTIONS

  defp move(position, :east, by) do
    Position.new(position.x + by, position.y)
  end

  defp move(position, :west, by) do
    Position.new(position.x - by, position.y)
  end

  defp move(position, :north, by) do
    Position.new(position.x, position.y - by)
  end

  defp move(position, :south, by) do
    Position.new(position.x, position.y + by)
  end
end
