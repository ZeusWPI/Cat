defmodule CatexWeb.HugLive.Index do
  use CatexWeb, :live_view

  alias Catex.Hugs
  alias Catex.Hugs.Hug

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :hugs, list_hugs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Hug")
    |> assign(:hug, Hugs.get_hug!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Hug")
    |> assign(:hug, %Hug{participants: []})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Hugs")
    |> assign(:hugs, list_hugs())
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    hug = Hugs.get_hug!(id)
    {:ok, _} = Hugs.delete_hug(hug)

    {:noreply, assign(socket, :hugs, list_hugs())}
  end

  defp list_hugs do
    Hugs.list_hugs()
    |> IO.inspect()
  end
end
