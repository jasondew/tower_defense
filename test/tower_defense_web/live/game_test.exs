defmodule TowerDefenseWeb.Live.GameTest do
  use TowerDefenseWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "game" do
    test "renders", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")
      assert html =~ "Tower Defense"
      assert render(view) =~ "Tower Defense"
    end
  end
end
