defmodule Catex.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :zeus_id, :integer
      add :admin, :boolean
      add :access_token, :string
      add :refresh_token, :string

      timestamps()
    end

    create unique_index("users", [:zeus_id])
  end
end
