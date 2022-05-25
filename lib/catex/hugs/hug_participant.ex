defmodule Catex.Hugs.HugParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hug_participants" do
    belongs_to :hug, Catex.Hugs.Hug
    belongs_to :user, Catex.Users.User

    field :status,
          Ecto.Enum,
          values: [:consent_pending, :consent_given, :consent_denied, :hug_pending, :hug_confirmed, :hug_denied]

    timestamps()
  end

  @doc false
  def changeset(hug_participant, attrs) do
    hug_participant
    |> cast(attrs, [])
    |> validate_required([])
  end
end
