defmodule TowerDefense.Game do
  use GenServer

  alias TowerDefense.Game.State

  @type tower :: :pellet | :squirt | :dart | :swarm | :frost | :bash
  @type position :: {non_neg_integer(), non_neg_integer()}

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

  def handle_call({:add_tower, tower, position}, _from, state) do
    updated_state =
      Map.update(
        state,
        :towers,
        [],
        &[%{type: tower, position: position} | &1]
      )

    {:reply, updated_state, updated_state}
  end

  ## PRIVATE FUNCTIONS
end
