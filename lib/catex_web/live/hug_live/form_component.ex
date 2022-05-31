defmodule CatexWeb.HugLive.FormComponent do
  @moduledoc false

  use CatexWeb, :live_component

  alias Catex.Hugs
  alias Catex.Hugs.HugParticipant
  alias Catex.Users

  @impl true
  def update(%{hug: hug} = assigns, socket) do
    changeset = Hugs.change_hug(hug)
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(
           :users,
           Users.list_users()
           |> Enum.filter(&(&1.id != assigns.current_user.id))
           |> Enum.map(&{&1.name, &1.id})
         )
      |> assign(
           :status_opts,
           #           [
           #             {"Consent pending", "consent_pending"},
           #             {"Consent given", "consent_given"},
           #             {"Consent denied", "consent_denied"},
           #             {"Hug pending", "hug_pending"},
           #             {"Hug confirmed", "hug_confirmed"},
           #             {"Hug denied", "hug_denied"}
           #           ],
           Hugs.status_flow()
         )
    }
  end

  @impl true
  def handle_event("add_participant", _params, socket) do
    participants =
      socket.assigns.changeset
      |> Ecto.Changeset.get_field(:participants, [])
        # The temp_id makes sure it does not overwrite the rest
      |> Enum.concat([%HugParticipant{temp_id: get_temp_id(), status: :consent_pending}])

    changeset = Ecto.Changeset.put_assoc(socket.assigns.changeset, :participants, participants)

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
    }
  end

  # JUST TO GENERATE A RANDOM STRING
  defp get_temp_id,
       do:
         :crypto.strong_rand_bytes(5)
         |> Base.url_encode64()
         |> binary_part(0, 5)

  @impl true
  def handle_event("validate", %{"hug" => hug_params} = assigns, socket) do
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
        {
          :noreply,
          socket
          |> put_flash(:info, "Hug updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_hug(socket, :new, hug_params) do
    case Hugs.create_hug(socket.assigns.current_user, hug_params) do
      {:ok, _hug} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Hug created successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
