defmodule TowerDefense.Game do
  use GenServer

  require Logger

  alias TowerDefense.Game.{
    Board,
    Creep,
    Level,
    Pathing,
    Position,
    State,
    Tile,
    Tower
  }

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

  @spec place_tower(pid(), Tower.model(), Position.t()) :: State.t()
  def place_tower(pid, model, %{x: x, y: y}) do
    GenServer.call(pid, {:place_tower, model, Position.new(x, y)})
  end

  @spec attempt_tower_placement(pid(), Position.t()) ::
          {:ok, Position.t()}
          | {:error, :paused | :out_of_bounds}
  def attempt_tower_placement(pid, %{x: x, y: y}) do
    GenServer.call(pid, {:attempt_tower_placement, Position.new(x, y)})
  end

  @spec send_next_level(pid()) :: State.t()
  def send_next_level(pid) do
    GenServer.call(pid, :send_next_level)
  end

  @spec send_creep(pid(), Creep.species()) :: State.t()
  def send_creep(pid, species) do
    GenServer.call(pid, {:send_creep, species})
  end

  @spec find_path([Tile.t()]) :: {:ok, [Tile.t()]} | {:error, :no_path}
  def find_path(tower_tiles) do
    middle = round(@tile_count / 2)
    start_tile = Tile.new(0, middle)
    end_tile = Tile.new(@tile_count - 1, middle)

    Pathing.find_path(start_tile, end_tile, tower_tiles, @tile_count)
  end

  ## CALLBACKS

  @impl GenServer
  def init(:ok) do
    {:ok, new_state()}
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

  def handle_call(:reset, _from, state) do
    updated_state =
      new_state()
      |> Map.put(:board, state.board)

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
        Map.put(state, :board, %Board{
          position: %{
            top_left: Position.new(x, y),
            bottom_right: Position.new(x + size - 1, y + size - 1)
          },
          size: size,
          tile_size: div(size, @tile_count)
        })

      {:reply, updated_state, updated_state}
    else
      raise "invalid board parameters: #{inspect(params)}"
    end
  end

  def handle_call(
        {:place_tower, model, position},
        _from,
        %{board: board} = state
      ) do
    if in_range?(board, position) do
      top_left_tile =
        Tile.from_position(position, board.position.top_left, board.tile_size)

      top_left_position =
        Position.from_tile(
          top_left_tile,
          board.position.top_left,
          board.tile_size
        )

      new_tower =
        Tower.new(model, top_left_tile, top_left_position, board.tile_size)

      updated_towers = [new_tower | state.towers]
      {:ok, updated_path} = find_path(Enum.flat_map(updated_towers, & &1.tiles))

      updated_state =
        state
        |> Map.put(:towers, updated_towers)
        |> Map.put(:path, updated_path)

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
    reply =
      with {_, true} <- {:range, in_range?(board, at)},
           top_left_tile =
             Tile.from_position(at, board.position.top_left, board.tile_size),
           top_left_position =
             Position.from_tile(
               top_left_tile,
               board.position.top_left,
               board.tile_size
             ),
           {_, false} <- {:colliding, colliding?(top_left_tile, towers)},
           {_, false} <- {:blocking, blocking?(top_left_tile, towers)} do
        {:ok, top_left_position}
      else
        {:range, false} -> {:error, :out_of_bounds}
        {:colliding, true} -> {:error, :colliding}
        {:blocking, true} -> {:error, :blocking}
      end

    {:reply, reply, state}
  end

  def handle_call(:send_next_level, _from, state) do
    # TODO: combine existing creep with with new creep queue from next level
    updated_level = state.level + 1

    updated_state =
      state
      |> Map.put(
        :creep_queue,
        Level.creeps(updated_level, entrance_position(state.board))
      )
      |> Map.put(:level, updated_level)

    {:reply, updated_state, updated_state}
  end

  def handle_call({:send_creep, species}, _from, state) do
    updated_state =
      state
      |> Map.put(
        :creep_queue,
        [[Creep.new(species, entrance_position(state.board))]]
      )

    {:reply, updated_state, updated_state}
  end

  ## PRIVATE FUNCTIONS

  defp new_state do
    {:ok, path} = find_path([])
    %State{path: path}
  end

  defp entrance_position(board) do
    0
    |> Tile.new(trunc(@tile_count / 2))
    |> Position.from_tile(board.position.top_left, board.tile_size, :center)
  end

  defp in_range?(
         %Board{
           position: %{top_left: top_left, bottom_right: bottom_right},
           tile_size: tile_size
         },
         %{x: x, y: y}
       ) do
    top_left.x <= x && x <= bottom_right.x - tile_size &&
      top_left.y <= y && y <= bottom_right.y - tile_size
  end

  defp colliding?(tile, towers) do
    Enum.any?(Tower.tiles_covered(tile), fn tile ->
      Enum.any?(towers, &Enum.member?(&1.tiles, tile))
    end)
  end

  defp blocking?(tile, towers) do
    tower_tiles =
      towers
      |> Enum.flat_map(& &1.tiles)
      |> Enum.concat(Tower.tiles_covered(tile))

    case find_path(tower_tiles) do
      {:ok, _path} -> false
      {:error, :no_path} -> true
    end
  end
end
