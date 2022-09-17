defmodule TowerDefense.Game.Creep do
  defstruct [:type, :position, :health, :speed]

  def new(type, position) do
    # TODO vary parameters depending on type
    %__MODULE__{
      type: type,
      position: position,
      health: 10,
      speed: 10
    }
  end

  def update(%__MODULE__{position: position, speed: speed} = creep) do
    Map.put(creep, :position, %{x: position.x + speed, y: position.y})
  end

  def in_bounds?(%__MODULE__{position: position}, _board) do
    # TODO add bounds to the board and check against that
    position.x < 780
  end
end
