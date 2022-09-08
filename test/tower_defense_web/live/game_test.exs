defmodule TowerDefenseWeb.Live.GameTest do
  use TowerDefenseWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "game" do
    test "initial render", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      assert html =~ "Tower Defense"
      assert render(view) =~ "Tower Defense"
      assert render(view) =~ "Time: 0"
      assert render(view) =~ "Level: 1"
      assert render(view) =~ "Lives: 20"
      assert render(view) =~ "Gold: 0"
      assert render(view) =~ "Score: 0"
    end

    test "starts/stops the timer when unpaused/paused", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, ~s|button[phx-click="toggle-pause"]|, "RESUME")

      assert view
             |> element(~s|button[phx-click="toggle-pause"]|)
             |> render_click()

      assert has_element?(view, ~s|button[phx-click="toggle-pause"]|, "PAUSE")
    end

    test "resets the game when the reset button is hit", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert view
             |> element(~s|button[phx-click="reset"]|, "RESET")
             |> render_click() =~ "Time: 0"
    end
  end
end
