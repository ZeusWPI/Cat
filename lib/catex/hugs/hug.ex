defmodule Catex.Hugs.Hug do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Catex.Hugs.HugParticipant

  schema "hugs" do
    has_many :participants, HugParticipant

    belongs_to :user, User, foreign_key: :initiator_id


    timestamps()
  end

  @doc false
  def changeset(hug, attrs) do
    hug
    |> cast(attrs, [:initiator_id])
    |> cast_assoc(:participants, with: &HugParticipant.changeset/2)
    |> validate_required([:initiator_id])
  end
end
