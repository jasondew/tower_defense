defmodule TowerDefense.Game.Projectile do
  defstruct [:from_position, :to_position, :progress]

  def new(from_position, to_position) do
    %__MODULE__{
      from_position: from_position,
      to_position: to_position,
      progress: 0
    }
  end
end
