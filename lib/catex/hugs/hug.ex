defmodule Catex.Hugs.Hug do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Catex.Hugs.HugParticipant
  alias Catex.Users.User

  schema "hugs" do
    has_many :participants, HugParticipant

    belongs_to :initiator, User


    timestamps()
  end

  @doc false
  def changeset(hug, attrs) do
    hug
    |> cast(attrs, [:initiator_id])
    |> cast_assoc(:participants, with: &HugParticipant.changeset/2)
    |> validate_required([:initiator_id])
  end

  def create_changeset(hug, attrs) do
    hug
    |> cast(attrs, [:initiator_id])
    |> cast_assoc(:initiator)
    |> assoc_constraint(:initiator)
    |> cast_assoc(:participants, with: &HugParticipant.create_changeset/2)
  end
end
