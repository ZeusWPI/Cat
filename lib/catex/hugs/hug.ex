defmodule Catex.Hugs.Hug do
  @moduledoc false

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
    |> cast_assoc(:participants, with: &HugParticipant.changeset/2)
    |> validate_required([])
  end
end
