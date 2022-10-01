defmodule TowerDefense.Game.State do
  alias TowerDefense.Game.Board

  defstruct time: 0,
            level: 1,
            lives: 20,
            gold: 0,
            score: 0,
            paused: true,
            board: %Board{},
            creeps: [],
            creep_queue: [],
            towers: [],
            path: [],
            projectiles: []

  alias TowerDefense.Game.{Creep, Projectile, Tower}

  def new, do: %__MODULE__{}

  def update(state) do
    updated_creeps =
      Enum.reduce(state.projectiles, state.creeps, fn projectile, creeps ->
        Enum.map(creeps, fn creep ->
          if creep.id == projectile.creep.id do
            %{creep | health: max(creep.health - projectile.damage, 0)}
          else
            creep
          end
        end)
      end)

    {updated_creeps, updated_score} =
      Enum.reduce(
        updated_creeps,
        {[], state.score},
        fn creep, {updated_creeps, updated_score} ->
          if creep.health > 0 do
            case Creep.update(creep, state) do
              nil -> {updated_creeps, updated_score - 10}
              updated_creep -> {[updated_creep | updated_creeps], updated_score}
            end
          else
            {updated_creeps, updated_score + 10}
          end
        end
      )

    updated_projectiles =
      Enum.reduce(state.towers, [], fn tower, projectiles ->
        case Tower.targeted_creep(tower, updated_creeps) do
          nil ->
            projectiles

          creep ->
            [
              Projectile.new(
                creep,
                Tower.damage(tower),
                tower.position.center,
                creep.position
              )
              | projectiles
            ]
        end
      end)

    {new_creeps, updated_creep_queue} =
      case state.creep_queue do
        [] -> {[], []}
        [new_creeps | updated_creep_queue] -> {new_creeps, updated_creep_queue}
      end

    state
    |> Map.put(:creeps, Enum.concat(new_creeps, updated_creeps))
    |> Map.put(:creep_queue, updated_creep_queue)
    |> Map.put(:score, updated_score)
    |> Map.put(:projectiles, updated_projectiles)
    |> Map.update(:time, 1, &(&1 + 1))
  end

  ## PRIVATE FUNCTIONS

  def in_bounds?(position, board) do
    board.position.top_left.x <= position.x &&
      position.x <= board.position.bottom_right.x &&
      board.position.top_left.y <= position.y &&
      position.y <= board.position.bottom_right.y
  end
end
