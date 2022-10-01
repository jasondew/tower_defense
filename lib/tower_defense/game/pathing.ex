defmodule TowerDefense.Game.Pathing do
  @moduledoc """
    uses an A* algorithm inspired by the fantastic blog post found here:
    https://www.redblobgames.com/pathfinding/a-star/introduction.html
  """

  alias __MODULE__.PathState
  alias TowerDefense.Game.{PriorityQueue, Tile}

  @max_iterations 10_000

  @spec find_path(Tile.t(), Tile.t(), [Tile.t()], non_neg_integer()) ::
          {:ok, [Tile.t()]} | {:error, :no_path}
  def find_path(start, destination, barriers, tile_count) do
    path_state = PathState.new(start, destination, barriers, tile_count)

    case Enum.reduce_while(
           1..@max_iterations,
           path_state,
           fn _iteration, path_state -> explore(path_state) end
         ) do
      nil ->
        {:error, :no_path}

      path_list ->
        path =
          path_list
          |> trace(destination)
          |> Enum.reverse()

        {:ok, path}
    end
  end

  @spec manhattan_distance(
          %{x: non_neg_integer(), y: non_neg_integer()},
          %{x: non_neg_integer(), y: non_neg_integer()}
        ) :: non_neg_integer()
  def manhattan_distance(a, b) do
    abs(a.x - b.x) + abs(a.y - b.y)
  end

  ## PRIVATE FUNCTIONS

  defmodule PathState do
    defstruct [:frontier, :path, :barriers, :tile_count, :destination, :current]

    def new(start, destination, barriers, tile_count) do
      %__MODULE__{
        frontier: PriorityQueue.put(PriorityQueue.new(), 0, start),
        path: %{start => {nil, 0}},
        barriers: barriers,
        tile_count: tile_count,
        destination: destination,
        current: nil
      }
    end

    def update(%__MODULE__{} = path_state, updates) do
      Map.merge(path_state, Map.new(updates))
    end
  end

  defp explore(path_state) do
    case PriorityQueue.get(path_state.frontier) do
      nil ->
        {:halt, nil}

      {current, frontier} ->
        if current == path_state.destination do
          {:halt, path_state.path}
        else
          {:cont,
           path_state
           |> PathState.update(current: current, frontier: frontier)
           |> explore_neighbors()}
        end
    end
  end

  defp explore_neighbors(path_state) do
    Enum.reduce(neighbors(path_state), path_state, fn next, path_state ->
      {_current, cost_to_current} = Map.get(path_state.path, path_state.current)
      new_cost = cost_to_current + 1

      case Map.get(path_state.path, next) do
        nil ->
          update_fronter_and_path(path_state, next, new_cost)

        {_start, cost_to_next} ->
          if new_cost < cost_to_next do
            update_fronter_and_path(path_state, next, new_cost)
          else
            path_state
          end
      end
    end)
  end

  defp update_fronter_and_path(path_state, next, new_cost) do
    priority = new_cost + heuristic_cost(next, path_state.destination)

    PathState.update(path_state,
      frontier: PriorityQueue.put(path_state.frontier, priority, next),
      path: Map.put(path_state.path, next, {path_state.current, new_cost})
    )
  end

  defp heuristic_cost(a, b) do
    manhattan_distance(a, b)
  end

  defp neighbors(%{current: current} = path_state) do
    for x <- (current.x - 1)..(current.x + 1),
        y <- (current.y - 1)..(current.y + 1),
        !(x == current.x && y == current.y),
        x >= 0,
        y >= 0,
        x < path_state.tile_count,
        y < path_state.tile_count,
        abs(x - current.x) + abs(y - current.y) == 1,
        Tile.new(x, y) not in path_state.barriers do
      Tile.new(x, y)
    end
  end

  defp trace(path, destination) do
    case Map.get(path, destination) do
      nil -> []
      {from, _cost} -> [destination | trace(path, from)]
    end
  end
end
