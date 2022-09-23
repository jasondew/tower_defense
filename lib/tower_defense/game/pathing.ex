defmodule TowerDefense.Game.Pathing do
  @moduledoc """
    inspired by the fantastic blog post found here:
    https://www.redblobgames.com/pathfinding/a-star/introduction.html
  """

  alias __MODULE__.PriorityQueue
  alias TowerDefense.Game.Tile

  @spec find_path(non_neg_integer(), Tile.t(), Tile.t()) ::
          {:ok, [Tile.t()]} | {:error, :no_path}
  def find_path(grid_size, from, to) do
    max_iterations = grid_size * grid_size

    frontier =
      (grid_size * 2)
      |> PriorityQueue.new()
      |> PriorityQueue.put(0, from)

    path_and_costs = %{from => {nil, 0}}

    path_and_costs =
      Enum.reduce_while(
        1..max_iterations,
        {frontier, path_and_costs},
        fn _iteration, {frontier, path_and_costs} ->
          {current, frontier} = PriorityQueue.get(frontier)

          if current == to do
            {:halt, path_and_costs}
          else
            {:cont,
             Enum.reduce(
               neighbors(current, grid_size),
               {frontier, path_and_costs},
               fn next, {frontier, path_and_costs} ->
                 {_current, cost_to_current} = Map.get(path_and_costs, current)
                 new_cost = cost_to_current + 1

                 case Map.get(path_and_costs, next) do
                   nil ->
                     update_frontier_and_path(
                       frontier,
                       path_and_costs,
                       current,
                       next,
                       to,
                       new_cost
                     )

                   {_from, cost_to_next} ->
                     if new_cost < cost_to_next do
                       update_frontier_and_path(
                         frontier,
                         path_and_costs,
                         current,
                         next,
                         to,
                         new_cost
                       )
                     else
                       {frontier, path_and_costs}
                     end
                 end
               end
             )}
          end
        end
      )

    path_and_costs
    |> trace_path(to)
    |> Enum.reverse()
  end

  ## PRIVATE FUNCTIONS

  defp update_frontier_and_path(
         frontier,
         path_and_costs,
         current,
         next,
         to,
         new_cost
       ) do
    priority = new_cost + heuristic_cost(next, to)
    frontier = PriorityQueue.put(frontier, priority, next)
    path_and_costs = Map.put(path_and_costs, next, {current, new_cost})

    {frontier, path_and_costs}
  end

  defp heuristic_cost(a, b) do
    abs(a.x - b.x) + abs(a.y - b.y)
  end

  defp neighbors(%{x: xx, y: yy}, max) do
    for x <- (xx - 1)..(xx + 1),
        y <- (yy - 1)..(yy + 1),
        !(x == xx && y == yy),
        x >= 0,
        y >= 0,
        x < max,
        y < max do
      Tile.new(x, y)
    end
  end

  defp trace_path(path_and_costs, to) do
    case Map.get(path_and_costs, to) do
      nil -> []
      {from, _cost} -> [to | trace_path(path_and_costs, from)]
    end
  end

  defmodule PriorityQueue do
    defstruct [:max_priority, :tree]

    def new(max_priority) do
      tree =
        Enum.reduce(0..max_priority, :gb_trees.empty(), fn key, tree ->
          :gb_trees.insert(key, [], tree)
        end)

      %__MODULE__{max_priority: max_priority, tree: tree}
    end

    def get(priority_queue, priority \\ 0)
    def get(%__MODULE__{max_priority: max_priority}, max_priority), do: nil

    def get(%__MODULE__{tree: tree} = priority_queue, priority) do
      case :gb_trees.get(priority, tree) do
        [] ->
          get(priority_queue, priority + 1)

        [head | rest] ->
          {head, update(priority, rest, tree)}
      end
    end

    def put(%__MODULE__{tree: tree}, priority, value) do
      values = :gb_trees.get(priority, tree)
      update(priority, [value | values], tree)
    end

    ## PRIVATE FUNCTIONS

    defp update(priority, value, tree) do
      %__MODULE__{tree: :gb_trees.update(priority, value, tree)}
    end
  end
end
