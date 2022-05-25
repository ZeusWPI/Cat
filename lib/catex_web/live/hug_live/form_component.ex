defmodule CatexWeb.HugLive.FormComponent do
  use CatexWeb, :live_component

  alias Catex.Hugs

  @impl true
  def update(%{hug: hug} = assigns, socket) do
    changeset = Hugs.change_hug(hug)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"hug" => hug_params}, socket) do
    changeset =
      socket.assigns.hug
      |> Hugs.change_hug(hug_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"hug" => hug_params}, socket) do
    save_hug(socket, socket.assigns.action, hug_params)
  end

  defp save_hug(socket, :edit, hug_params) do
    case Hugs.update_hug(socket.assigns.hug, hug_params) do
      {:ok, _hug} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hug updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_hug(socket, :new, hug_params) do
    case Hugs.create_hug(hug_params) do
      {:ok, _hug} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hug created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
