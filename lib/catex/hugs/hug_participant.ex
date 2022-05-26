defmodule Catex.Hugs.HugParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hug_participants" do
    belongs_to :hug, Catex.Hugs.Hug
    belongs_to :user, Catex.Users.User

    field :temp_id, :string, virtual: true

    field :status,
          Ecto.Enum,
          values: [:consent_pending, :consent_given, :consent_denied, :hug_pending, :hug_confirmed, :hug_denied]

    timestamps()
  end

  @doc false
  def changeset(hug_participant, attrs) do
    hug_participant
    |> Map.put(:temp_id, (hug_participant.temp_id || attrs["temp_id"])) # So its persisted
    |> cast(attrs, [:hug, :user, :status])
    |> validate_required([:hug, :user, :status])
  end
end
