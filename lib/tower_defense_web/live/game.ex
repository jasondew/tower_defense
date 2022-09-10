defmodule TowerDefenseWeb.Live.Game do
  use TowerDefenseWeb, :live_view

  import TowerDefenseWeb.Live.Components

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

  @towers [:pellet, :squirt, :dart, :swarm, :frost, :bash]

  alias TowerDefense.Game

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    config = %{levels: @levels, status_colors: @status_colors, towers: @towers}

    unmounted_assigns = %{
      config: config,
      state: %Game.State{},
      selected_tower: nil,
      mouse_position: nil
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
        "place-tower",
        _params,
        %{
          assigns: %{
            game_pid: game_pid,
            state: %{board: board},
            selected_tower: tower,
            mouse_position: %{x: x, y: y}
          }
        } = socket
      )
      when not is_nil(tower) do
    {:noreply,
     assign(socket,
       state: Game.place_tower(game_pid, tower, %{x: x - board.tile_size, y: y - board.tile_size})
     )}
  end

  def handle_event("place-tower", _params, socket), do: {:noreply, socket}

  def handle_event(
        "update-board-disposition",
        %{"x" => x, "y" => y, "size" => size},
        %{assigns: %{game_pid: game_pid}} = socket
      ) do
    {:noreply,
     assign(
       socket,
       state: Game.set_board_disposition(game_pid, %{x: x, y: y, size: size})
     )}
  end

  def handle_event("update-mouse-position", %{"x" => x, "y" => y}, socket) do
    {:noreply, assign(socket, mouse_position: %{x: x, y: y})}
  end

  ## PRIVATE FUNCTIONS

  defp mouse_over_board(board, %{x: x, y: y}) do
    board.position.x <= x && x <= board.position.x + board.size &&
      board.position.y <= y && y <= board.position.y + board.size
  end

  defp mouse_over_board(_board, _mouse_position), do: false
end
