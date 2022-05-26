defmodule Catex.Hugs.Hug do
  use Ecto.Schema
  import Ecto.Changeset

  alias Catex.Hugs.HugParticipant

  schema "hugs" do
    has_many :participants, HugParticipant

    timestamps()
  end

  @doc false
  def changeset(hug, attrs) do
    hug
    |> cast(attrs, [])
    |> cast_assoc(:participants)
    |> validate_required([])
  end
end
