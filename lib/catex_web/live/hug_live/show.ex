defmodule CatexWeb.HugLive.Show do
  use CatexWeb, :live_view

  alias Catex.Hugs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:hug, Hugs.get_hug!(id))}
  end

  defp page_title(:show), do: "Show Hug"
  defp page_title(:edit), do: "Edit Hug"
end
