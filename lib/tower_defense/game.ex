defmodule TowerDefense.Game do
  use GenServer

  require Logger

  alias TowerDefense.Game.{Board, Creep, State, Tower}

  @type tower_type :: :pellet | :squirt | :dart | :swarm | :frost | :bash
  @type position :: %{x: non_neg_integer(), y: non_neg_integer()}

  @tile_count 26

  ## PUBLIC API

  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  @spec tick(pid()) :: State.t()
  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  @spec toggle_pause(pid()) :: State.t()
  def toggle_pause(pid) do
    GenServer.call(pid, :toggle_pause)
  end

  @spec reset(pid()) :: State.t()
  def reset(pid) do
    GenServer.call(pid, :reset)
  end

  @spec get_state(pid()) :: State.t()
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  @spec set_board_disposition(pid(), %{
          top: non_neg_integer(),
          left: non_neg_integer(),
          bottom: pos_integer(),
          right: pos_integer()
        }) :: State.t()
  def set_board_disposition(pid, parameters) do
    GenServer.call(pid, {:set_board_disposition, parameters})
  end

  @spec place_tower(pid(), tower_type, position) :: State.t()
  def place_tower(pid, type, position) do
    GenServer.call(pid, {:place_tower, type, position})
  end

  @spec attempt_tower_placement(pid(), position) ::
          {:ok, position}
          | {:error, :paused | :out_of_bounds}
  def attempt_tower_placement(pid, position) do
    GenServer.call(pid, {:attempt_tower_placement, position})
  end

  @spec send_next_level(pid()) :: State.t()
  def send_next_level(pid) do
    GenServer.call(pid, :send_next_level)
  end

  ## CALLBACKS

  @impl GenServer
  def init(:ok) do
    {:ok, %State{}}
  end

  @impl GenServer
  def handle_call(:tick, _from, state) do
    if state.paused do
      {:reply, state, state}
    else
      updated_state = State.update(state)

      {:reply, updated_state, updated_state}
    end
  end

  def handle_call(:toggle_pause, _from, state) do
    updated_state = Map.update(state, :paused, true, &(!&1))
    {:reply, updated_state, updated_state}
  end

  def handle_call(:reset, _from, _state) do
    updated_state = %State{}
    {:reply, updated_state, updated_state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(
        {:set_board_disposition, %{x: x, y: y, size: size} = params},
        _from,
        state
      ) do
    if rem(size, @tile_count) == 0 do
      updated_state =
        Map.put(state, :board, %{
          position: %{x: x, y: y},
          size: size,
          tile_size: div(size, @tile_count)
        })

      {:reply, updated_state, updated_state}
    else
      raise "invalid board parameters: #{inspect(params)}"
    end
  end

  def handle_call(
        {:place_tower, type, position},
        _from,
        %{board: board} = state
      ) do
    %{tile: tile, position: position} = Board.tile_and_position(position, board)

    if tile.x >= 0 || tile.y >= 0 || tile.x < @tile_count ||
         tile.y < @tile_count do
      updated_state =
        Map.update(
          state,
          :towers,
          [],
          &[Tower.new(type, tile, position, board.tile_size) | &1]
        )

      {:reply, updated_state, updated_state}
    else
      Logger.warn(
        "received click event outside of board: at=#{inspect(position)} board=#{inspect(board)}"
      )

      {:reply, state, state}
    end
  end

  def handle_call(
        {:attempt_tower_placement, _position},
        _from,
        %{paused: true} = state
      ) do
    {:reply, {:error, :paused}, state}
  end

  def handle_call(
        {:attempt_tower_placement, at},
        _from,
        %{board: board, towers: towers} = state
      ) do
    # TODO: validate it isn't blocking
    reply =
      with {_, true} <- {:range, in_range?(board, at)},
           %{tile: tile, position: position} <-
             Board.tile_and_position(at, board),
           {_, false} <- {:colliding, colliding?(tile, towers)} do
        {:ok, position}
      else
        {:range, false} -> {:error, :out_of_bounds}
        {:colliding, true} -> {:error, :colliding}
      end

    {:reply, reply, state}
  end

  def handle_call(:send_next_level, _from, state) do
    updated_state =
      state
      |> Map.update(
        :creeps,
        [],
        &Enum.concat(next_level_creeps(state), &1)
      )
      |> Map.update(:level, 1, &(&1 + 1))

    {:reply, updated_state, updated_state}
  end

  ## PRIVATE FUNCTIONS

  defp next_level_creeps(_state) do
    # TODO vary depending on level
    # TODO figure out entrance

    [Creep.new(:normal, %{x: 0, y: 440})]
  end

  defp in_range?(board, %{x: x, y: y}) do
    board.position.x <= x &&
      x <= board.position.x + board.size - board.tile_size &&
      board.position.y <= y &&
      y <= board.position.y + board.size - board.tile_size
  end

  defp colliding?(%{x: x, y: y}, towers) do
    Enum.any?(towers, fn %Tower{tile: %{x: tower_x, y: tower_y}} ->
      (x == tower_x - 1 || x == tower_x || x == tower_x + 1) &&
        (y == tower_y - 1 || y == tower_y || y == tower_y + 1)
    end)
  end
end
