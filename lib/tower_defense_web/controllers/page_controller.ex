defmodule TowerDefenseWeb.PageController do
  use TowerDefenseWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
