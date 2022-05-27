defmodule Catex.Users.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :zeus_id, :integer
    field :admin, :boolean
    field :access_token, :string
    field :refresh_token, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :zeus_id, :admin, :access_token, :refresh_token])
    |> validate_required([:name, :zeus_id, :admin])
  end
end
