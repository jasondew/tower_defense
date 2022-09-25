defmodule TowerDefense.Game.Creep do
  defstruct [:type, :position, :heading, :health, :speed]

  alias TowerDefense.Game.{Pathing, Position, Tile}

  def new(type, position, speed \\ 10) do
    # TODO vary parameters depending on type
    %__MODULE__{
      type: type,
      position: position,
      heading: :east,
      health: 10,
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
    # TODO: create a center-line path for the creeps to follow and adjust
    # positioning, start, etc accordingly
    current_tile = Tile.from_position(creep.position, offset, tile_size)

    next_tile =
      case Enum.find_index(path, &(&1 == current_tile)) do
        nil ->
          # TODO: probably need to generate specific paths to get them back on track
          Enum.min_by(path, fn tile ->
            tile_top_left =
              Position.from_tile(tile, offset, tile_size, :top_left)

            Pathing.manhattan_distance(creep.position, tile_top_left)
          end)

        current_index ->
          Enum.at(path, current_index + 1) || current_tile
      end

    new_heading =
      cond do
        Tile.from_position(
          move(position, heading, speed),
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

    new_position = move(position, new_heading, speed)

    creep
    |> Map.put(:position, new_position)
    |> Map.put(:heading, new_heading)
  end

  ## PRIVATE FUNCTIONS

  defp move(position, :east, speed) do
    Position.new(position.x + speed, position.y)
  end

  defp move(position, :west, speed) do
    Position.new(position.x - speed, position.y)
  end

  defp move(position, :north, speed) do
    Position.new(position.x, position.y - speed)
  end

  defp move(position, :south, speed) do
    Position.new(position.x, position.y + speed)
  end
end
