defmodule Catex.Repo.Migrations.CreateHugs do
  use Ecto.Migration

  def change do
    create table(:hugs) do
      add :initiator_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end
  end
end
