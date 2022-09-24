defmodule TowerDefense.Game.PriorityQueue do
  defstruct [:tree]

  def new do
    %__MODULE__{tree: :gb_trees.empty()}
  end

  def get(%__MODULE__{tree: tree}) do
    if :gb_trees.is_empty(tree) do
      nil
    else
      {priority, [value | rest]} = :gb_trees.smallest(tree)

      tree =
        case rest do
          [] -> :gb_trees.delete(priority, tree)
          _nonempty -> :gb_trees.update(priority, rest, tree)
        end

      {value, %__MODULE__{tree: tree}}
    end
  end

  def put(%__MODULE__{tree: tree}, priority, value) do
    values =
      if :gb_trees.is_defined(priority, tree) do
        :gb_trees.get(priority, tree)
      else
        []
      end

    tree = :gb_trees.delete_any(priority, tree)
    tree = :gb_trees.insert(priority, [value | values], tree)

    %__MODULE__{tree: tree}
  end
end
