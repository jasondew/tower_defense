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

  @spec place_tower(pid(), tower, position) :: State.t()
  def place_tower(pid, tower, position) do
    GenServer.call(pid, {:place_tower, tower, position})
  end

  @spec tile_and_position(non_neg_integer(), :x | :y, map()) :: %{
          tile: non_neg_integer(),
          position: non_neg_integer()
        }
  def tile_and_position(x, :x, board) do
    tile = tile(x, board.position.x, board.tile_size)

    %{tile: tile, position: tile * board.tile_size + board.position.x}
  end

  def tile_and_position(y, :y, board) do
    tile = tile(y, board.position.y, board.tile_size)

    %{tile: tile, position: tile * board.tile_size + board.position.y}
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
        {:place_tower, tower, position},
        _from,
        %{board: board} = state
      ) do
    %{tile: tile_x, position: position_x} = tile_and_position(position.x, :x, board)
    %{tile: tile_y, position: position_y} = tile_and_position(position.y, :y, board)

    if tile_x >= 0 || tile_y >= 0 || tile_x < @tile_count || tile_y < @tile_count do
      updated_state =
        Map.update(
          state,
          :towers,
          [],
          &[
            %{
              type: tower,
              position: {position_x, position_y},
              tile_position: %{x: tile_x, y: tile_y}
            }
            | &1
          ]
        )

      {:reply, updated_state, updated_state}
    else
      Logger.warn(
        "received click event outside of board: at=#{inspect(position)} board=#{inspect(board)}"
      )

      {:reply, state, state}
    end
  end

  ## PRIVATE FUNCTIONS

  defp tile(coordinate, offset, tile_size) do
    trunc((coordinate - offset) / tile_size)
  end
end
