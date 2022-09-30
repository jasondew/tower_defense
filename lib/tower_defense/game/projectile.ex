defmodule TowerDefense.Game.Projectile do
  defstruct [:creep, :damage, :from_position, :to_position]

  def new(creep, damage, from_position, to_position) do
    %__MODULE__{
      creep: creep,
      damage: damage,
      from_position: from_position,
      to_position: to_position
    }
  end
end
