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
            towers: []

  alias TowerDefense.Game.Creep

  def new, do: %__MODULE__{}

  def update(state) do
    {updated_creeps, updated_score} =
      Enum.reduce(
        state.creeps,
        {[], state.score},
        fn creep, {updated_creeps, updated_score} ->
          updated_creep = Creep.update(creep)

          if in_bounds?(updated_creep.position, state.board) do
            {[updated_creep | updated_creeps], updated_score}
          else
            {updated_creeps, updated_score - 10}
          end
        end
      )

    state
    |> Map.put(:creeps, updated_creeps)
    |> Map.put(:score, updated_score)
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
