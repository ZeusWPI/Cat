defmodule Catex.Repo.Migrations.CreateHugs do
  use Ecto.Migration

  def change do
    create table(:hugs) do
      timestamps()
    end
  end
end
