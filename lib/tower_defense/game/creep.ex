defmodule TowerDefense.Game.Creep do
  defstruct [
    :id,
    :heading,
    :health,
    :maximum_health,
    :position,
    # must be <= 1.0
    :speed,
    :type
  ]

  alias TowerDefense.Game.{Position, Tile}

  def new(type, position, speed \\ 1.0) do
    # TODO vary parameters depending on type
    %__MODULE__{
      id: UUID.uuid4(),
      type: type,
      position: position,
      heading: :east,
      health: 10,
      maximum_health: 10,
      speed: speed
    }
  end

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
