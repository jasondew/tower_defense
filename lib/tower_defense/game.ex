defmodule TowerDefense.Game do
  use GenServer

  @type game_state :: map()

  ## PUBLIC API

  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  @spec tick(pid()) :: game_state()
  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  @spec get_state(pid()) :: game_state()
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  ## CALLBACKS

  @impl GenServer
  def init(:ok) do
    {:ok, initial_state()}
  end

  @impl GenServer
  def handle_call(:tick, _from, state) do
    updated_state = Map.update(state, :time, 1, &(&1 + 1))
    {:reply, updated_state, updated_state}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  ## PRIVATE FUNCTIONS

  defp initial_state do
    %{
      time: 0,
      level: 1,
      lives: 20,
      gold: 0,
      score: 0
    }
  end
end
