defmodule TowerDefenseWeb.Live.Game do
  use TowerDefenseWeb, :live_view

  @one_second 1_000
  @status_colors [
    normal: "bg-gray-500",
    group: "bg-blue-500",
    immune: "bg-purple-500",
    fast: "bg-red-500",
    spawn: "bg-green-500",
    flying: "bg-yellow-500",
    boss: "bg-teal-500"
  ]

  @levels [
    {1, :normal},
    {2, :normal},
    {3, :group},
    {4, :immune},
    {5, :fast},
    {6, :spawn},
    {7, :flying},
    {8, :boss}
  ]

  @towers [
    pellet: %{symbol: "→"},
    squirt: %{symbol: "▶︎"},
    dart: %{symbol: "⇞"},
    swarm: %{symbol: "⏅"},
    frost: %{symbol: "❄︎"},
    bash: %{symbol: "◎"}
  ]

  alias TowerDefense.Game

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    config = %{levels: @levels, status_colors: @status_colors, towers: @towers}

    assigns =
      if connected?(socket) do
        {:ok, game_pid} = Game.start_link([])
        game_state = Game.get_state(game_pid)
        :timer.send_interval(@one_second, :tick)

        %{config: config, game_pid: game_pid, game_state: game_state}
      else
        %{config: config, game_state: %{}}
      end

    {:ok, assign(socket, assigns)}
  end

  @impl Phoenix.LiveView
  def handle_info(:tick, %{assigns: %{game_pid: game_pid}} = socket) do
    {:noreply, assign(socket, game_state: Game.tick(game_pid))}
  end
end
