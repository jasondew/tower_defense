defmodule TowerDefense.Game.Creep do
  defstruct [:type, :position, :health, :speed]

  def new(type, start_position, _end_position) do
    # TODO vary parameters depending on type
    %__MODULE__{
      type: type,
      position: start_position,
      health: 10,
      speed: 10
    }
  end

  def update(%__MODULE__{position: position, speed: speed} = creep) do
    Map.put(creep, :position, %{x: position.x + speed, y: position.y})
  end
end
