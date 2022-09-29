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
        <div class={"w-[#{round(100 * assigns.health / assigns.maximum_health)}%] h-[2px] bg-red-500"}></div>
      </div>

      <div class={rotation_class(assigns.heading)}>
        <%= creep_symbol(@type) %>
      </div>
    </div>
    """
  end

  def projectile(assigns) do
    ~H"""
    <polyline style="fill: none; stroke-width: 2; stroke: red;"
      points={"
        #{assigns.from.x},#{assigns.from.y}
        #{assigns.to.x},#{assigns.to.y}
      "}
    >
    </polyline>
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
      left: #{x - range}px;
      top: #{y - range}px;
      width: #{size + 2 * range}px;
      height: #{size + 2 * range}px;
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

  defp projectile_style(%{from: from, to: to}) do
    """
      #{style(from)}
      width: #{size(from.x, to.x)}px;
      height: 2px;
      transform: rotate(#{degrees(from, to)}deg);
    """
  end

  defp degrees(from, to) do
    round(
      180 * :math.atan((to.y - from.y) / (to.x - from.x)) / :math.pi() + 180
    )
  end

  defp size(a, b), do: abs(a - b)

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
