defmodule Catex.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :gender, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :gender])
    |> validate_required([:name, :gender])
  end
end
