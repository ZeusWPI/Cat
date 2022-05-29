defmodule CatexWeb.HugLive.FormComponent do
  @moduledoc false

  use CatexWeb, :live_component

  alias Catex.Hugs
  alias Catex.Hugs.Hug
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

  defp prep_params(assigns, params) do
    participants = Map.get(params, "participants", [])
                   |> Map.values
                   |> Enum.map(&(Map.put(&1, "status", :consent_pending)))
                   |> Enum.concat(
                        [
                          %{user_id: assigns.current_user.id, status: "consent_given"}
                        ]
                      )
    params = params
             |> Map.put("participants", participants)
             |> Map.put("initiator_id", assigns.current_user.id)
  end

  @impl true
  def handle_event("add_participant", _params, socket) do
    existing_participants = Map.get(socket.assigns.hug, :participants, [])

    participants =
      existing_participants
      |> Enum.concat(
           [
             #        %HugParticipant{temp_id: get_temp_id(), status: :consent_pending}
             %HugParticipant{}
             #        Hugs.change_participant(%HugParticipant{}) # NOTE temp_id
           ]
         )

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:participants, participants)

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
      |> Hugs.change_hug(prep_params(assigns, hug_params))
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
    hug_params = prep_params(socket.assigns, hug_params)

    case Hugs.create_hug(hug_params) do
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
