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
        <%= symbol(assigns.type) %>
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

  ## PRIVATE FUNCTIONS

  defp style(%{size: size, x: x, y: y}) do
    """
      #{style(%{size: size})}
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

  defp symbol(:pellet), do: "→"
  defp symbol(:squirt), do: "▶︎"
  defp symbol(:dart), do: "⇞"
  defp symbol(:swarm), do: "⏅"
  defp symbol(:frost), do: "❄︎"
  defp symbol(:bash), do: "◎"
end
