defmodule Catex.Hugs.HugParticipant do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Catex.Hugs.Hug
  alias Catex.Users.User

  schema "hug_participants" do
    belongs_to :hug, Hug
    belongs_to :user, User

    field :temp_id, :string, virtual: true

    field :status,
          Ecto.Enum,
          values: [:consent_pending, :consent_given, :consent_denied, :hug_pending, :hug_confirmed, :hug_denied]

    timestamps()
  end

  @doc false
  def changeset(hug_participant, attrs) do
    hug_participant
    # So its persisted
    |> Map.put(:temp_id, hug_participant.temp_id || attrs["temp_id"])
    |> cast(attrs, [:user_id, :status, :temp_id])
    |> validate_required([:user_id, :status])
    |> assoc_constraint(:user)
  end

  def create_changeset(hug_participant, attrs) do
    hug_participant
    |> cast(attrs, [:user_id, :temp_id, :status])
    |> validate_required([:user_id, :status])
    |> assoc_constraint(:user)
  end
end
