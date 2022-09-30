defmodule TowerDefenseWeb.Live.Components do
  use Phoenix.Component

  def tower(assigns) do
    ~H"""
    <div>
      <div
        class={"
          z-10 text-center text-gray-800 bg-gray-100
          border border-2 cursor-pointer
          #{
            if assigns[:selected],
            do: "border-orange-500 border-solid",
            else: "border-gray-600 border-dotted"
          }
        "}
        style={style(assigns)}
        {assigns_to_attributes(assigns, [:size, :type, :range, :display_range, :x, :y])}
      >
        <%= tower_symbol(assigns.type) %>
      </div>

      <%= if assigns[:display_range] do %>
        <div
          class="z-0 bg-red-100 bg-opacity-25 border border-orange-500 rounded-full"
        style={range_style(assigns)}
        >
        </div>
      <% end %>
    </div>
    """
  end

  def creep(assigns) do
    ~H"""
    <div
      style={style(assigns)}
      class={"
        w-[#{assigns.size}px]
        h-[#{assigns.size}px]
        flex
        justify-center
      "}
    >
      <div class={"w-11/12 h-[4px] top-[2px] left-[2px] absolute flex border border-red-500"}>
        <div
          class={" h-[2px] bg-red-500"}
          style={"width: #{round(100 * assigns.health / assigns.maximum_health)}%;"}
        ></div>
      </div>

      <div class={rotation_class(assigns.heading)}>
        <%= creep_symbol(@type) %>
      </div>
    </div>
    """
  end

  def projectile(%{from: from, to: to, size: size, color: color} = assigns) do
    ~H"""
    <div id={UUID.uuid4()} style={"
      width: #{size}px;
      height: #{size}px;
      background-color: #{color};
      border-radius: 50%;
      offset-path: path('M#{from.x} #{from.y} T#{to.x} #{to.y}');
      offset-distance: 0%;
      animation: projectile 0.5s linear;
      animation-fill-mode: forwards;
    "}></div>
    """
  end

  def tile(assigns) do
    ~H"""
    <div style={tile_style(assigns)} class="bg-orange-500 opacity-10"></div>
    """
  end

  ## PRIVATE FUNCTIONS

  defp style(%{size: size, x: x, y: y}) do
    """
      #{style(%{size: size})}
      #{style(%{x: x, y: y})}
      position: absolute;
      left: #{x}px;
      top: #{y}px;
    """
  end

  defp style(%{x: x, y: y}) do
    """
      position: absolute;
      left: #{x}px;
      top: #{y}px;
    """
  end

  defp style(%{size: size}) do
    """
      width: #{size}px;
      height: #{size}px;
      font-size: #{size * 0.6}px;
    """
  end

  defp range_style(%{size: size, range: range, x: x, y: y}) do
    """
      position: absolute;
      left: #{x - size}px;
      top: #{y - size}px;
      width: #{2 * range}px;
      height: #{2 * range}px;
    """
  end

  defp tile_style(%{x: x, y: y, size: size}) do
    """
      position: absolute;
      left: #{x * size}px;
      top: #{y * size}px;
      width: #{size}px;
      height: #{size}px;
    """
  end

  defp rotation_class(:north), do: "rotate-0"
  defp rotation_class(:east), do: "rotate-90"
  defp rotation_class(:south), do: "rotate-180"
  defp rotation_class(:west), do: "rotate-270"

  defp tower_symbol(:pellet), do: "→"
  defp tower_symbol(:squirt), do: "▶︎"
  defp tower_symbol(:dart), do: "⇞"
  defp tower_symbol(:swarm), do: "⏅"
  defp tower_symbol(:frost), do: "❄︎"
  defp tower_symbol(:bash), do: "◎"

  defp creep_symbol(:normal), do: "🐞"
end
