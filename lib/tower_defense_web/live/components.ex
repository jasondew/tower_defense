defmodule TowerDefenseWeb.Live.Components do
  use Phoenix.Component

  def tower(assigns) do
    ~H"""
    <div
      class={"
        w-[30px] h-[30px] text-[17px] text-center text-gray-800
        bg-gray-100 border border-2 cursor-pointer
        #{
          if assigns[:selected],
          do: "border-orange-500 border-solid",
          else: "border-gray-600 border-dotted"
        }
      "}
      {assigns_to_attributes(assigns)}
    >
      <%= symbol(assigns.type) %>
    </div>
    """
  end

  ## PRIVATE FUNCTIONS

  defp symbol(:pellet), do: "→"
  defp symbol(:squirt), do: "▶︎"
  defp symbol(:dart), do: "⇞"
  defp symbol(:swarm), do: "⏅"
  defp symbol(:frost), do: "❄︎"
  defp symbol(:bash), do: "◎"
end
