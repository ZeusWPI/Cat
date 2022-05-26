defmodule Catex.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :zeus_id, :integer
      add :admin, :boolean, null: false, default: false
      add :access_token, :string
      add :refresh_token, :string

      timestamps()
    end

    create unique_index("users", [:zeus_id])
  end
end
