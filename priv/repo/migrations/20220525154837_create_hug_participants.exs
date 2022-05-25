defmodule Catex.Repo.Migrations.CreateHugRelations do
  use Ecto.Migration

  def change do
    create_query =
      "CREATE TYPE hug_participant_status AS ENUM ('consent_pending', 'consent_given', 'consent_denied', 'hug_pending', 'hug_confirmed', 'hug_denied')"

    drop_query = "DROP TYPE hug_participant_status"
    execute(create_query, drop_query)

    create table(:hug_participants) do
      add :user_id, references(:users, on_delete: :nothing)
      add :hug_id, references(:hugs, on_delete: :nothing)

      add :status, :hug_participant_status

      timestamps()
    end

    create index(:hug_participants, [:user_id])
    create index(:hug_participants, [:hug_id])
  end
end
