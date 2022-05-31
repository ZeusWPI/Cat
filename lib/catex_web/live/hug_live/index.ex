defmodule CatexWeb.HugLive.Index do
  @moduledoc false

  use CatexWeb, :live_view

  alias Catex.Hugs
  alias Catex.Hugs.Hug
  alias Catex.Users

  @impl true
  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    {
      :ok,
      socket
      |> assign_new(:current_user, fn -> Users.get_user!(user_id) end)
      |> assign(:hugs, list_hugs(user_id))
    }
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
    |> assign(:hugs, list_hugs(socket.assigns.current_user.id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    hug = Hugs.get_hug!(id)
    {:ok, _} = Hugs.delete_hug(hug)

    {:noreply, assign(socket, :hugs, list_hugs(socket.assigns.current_user.id))}
  end

  defp list_hugs(user_id) do
    Hugs.list_hugs_from_user(user_id)
  end
end
