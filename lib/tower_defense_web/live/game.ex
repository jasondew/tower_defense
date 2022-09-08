defmodule TowerDefenseWeb.Live.Game do
  use TowerDefenseWeb, :live_view

  import TowerDefenseWeb.Live.Components

  @one_second 1_000
  @board_static_offset 10

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

  @towers [:pellet, :squirt, :dart, :swarm, :frost, :bash]

  alias TowerDefense.Game

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    config = %{levels: @levels, status_colors: @status_colors, towers: @towers}

    unmounted_assigns = %{
      config: config,
      state: %Game.State{},
      selected_tower: nil,
      board_position: nil
    }

    assigns =
      if connected?(socket) do
        {:ok, game_pid} = Game.start_link([])
        state = Game.get_state(game_pid)
        :timer.send_interval(@one_second, :tick)

        Map.merge(unmounted_assigns, %{game_pid: game_pid, state: state})
      else
        unmounted_assigns
      end

    {:ok, assign(socket, assigns)}
  end

  @impl Phoenix.LiveView
  def handle_info(:tick, %{assigns: %{game_pid: game_pid}} = socket) do
    {:noreply, assign(socket, state: Game.tick(game_pid))}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle-pause", _unsigned_params, %{assigns: %{game_pid: game_pid}} = socket) do
    {:noreply, assign(socket, state: Game.toggle_pause(game_pid))}
  end

  def handle_event("reset", _unsigned_params, %{assigns: %{game_pid: game_pid}} = socket) do
    {:noreply, assign(socket, state: Game.reset(game_pid))}
  end

  def handle_event(
        "select-tower",
        %{"type" => type},
        %{assigns: %{selected_tower: current_tower}} = socket
      ) do
    new_tower = String.to_existing_atom(type)

    selected_tower =
      if new_tower == current_tower do
        nil
      else
        new_tower
      end

    {:noreply, assign(socket, selected_tower: selected_tower)}
  end

  def handle_event(
        "board-click",
        %{"clientX" => x, "clientY" => y},
        %{assigns: %{game_pid: game_pid, selected_tower: tower, board_position: board_position}} =
          socket
      ) do
    if tower && board_position do
      position = {
        tile(x, board_position[:left]),
        tile(y, board_position[:top])
      }

      {:noreply, assign(socket, state: Game.add_tower(game_pid, tower, position))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("board-position", %{"top" => top, "left" => left}, socket) do
    {:noreply, assign(socket, board_position: %{top: top, left: left})}
  end

  ## PRIVATE FUNCTIONS

  defp tile(coordinate, offset) do
    trunc((coordinate - offset - @board_static_offset) / 30)
  end
end
