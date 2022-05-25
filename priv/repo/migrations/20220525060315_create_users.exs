defmodule Catex.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :gender, :string

      timestamps()
    end
  end
end
