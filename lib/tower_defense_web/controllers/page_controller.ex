defmodule TowerDefenseWeb.PageController do
  use TowerDefenseWeb, :controller

  @status_colors [
    normal: "bg-gray-500",
    group: "bg-blue-500",
    immune: "bg-purple-500",
    fast: "bg-red-500",
    spawn: "bg-green-500",
    flying: "bg-yellow-500",
    boss: "bg-teal-500"
  ]

  @towers [
    pellet: %{symbol: "→"},
    squirt: %{symbol: "▶︎"},
    dart: %{symbol: "⇞"},
    swarm: %{symbol: "⏅"},
    frost: %{symbol: "❄︎"},
    bash: %{symbol: "◎"}
  ]

  def index(conn, _params) do
    render(conn, "index.html", status_colors: @status_colors, towers: @towers)
  end
end
