defmodule TowerDefense.Game do
  use GenServer

  require Logger

  alias TowerDefense.Game.State

  @type tower :: :pellet | :squirt | :dart | :swarm | :frost | :bash
  @type position :: {non_neg_integer(), non_neg_integer()}

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

  @spec add_tower(pid(), tower, position) :: State.t()
  def add_tower(pid, tower, position) do
    GenServer.call(pid, {:add_tower, tower, position})
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
      updated_state = Map.update(state, :time, 1, &(&1 + 1))
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
        {:add_tower, tower, {x, y}},
        _from,
        %{board: board} = state
      ) do
    tile_x = tile(x, board.position.x, board.tile_size)
    tile_y = tile(y, board.position.y, board.tile_size)

    if tile_x < 0 || tile_y < 0 || tile_x > @tile_count - 2 || tile_y > @tile_count - 2 do
      Logger.warn(
        "received click event outside of board: at=#{inspect({x, y})} board=#{inspect(board)}"
      )

      {:reply, state, state}
    else
      updated_state =
        Map.update(
          state,
          :towers,
          [],
          &[
            %{
              type: tower,
              position: {tile_x * board.tile_size, tile_y * board.tile_size},
              tile_position: {tile_x, tile_y}
            }
            | &1
          ]
        )

      {:reply, updated_state, updated_state}
    end
  end

  ## PRIVATE FUNCTIONS

  defp tile(coordinate, offset, tile_size) do
    trunc((coordinate - offset) / tile_size)
  end
end
