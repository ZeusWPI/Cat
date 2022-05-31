# How to run this?
# > OLD_DB_URL="ecto://<USERNAME>:<PASSWORD>@localhost:<PORT>/<DB>" mix run priv/repo/migrate_data.exs

old_db_url = System.get_env("OLD_DB_URL") || raise("Missing OLD_DB_URL!")

import Ecto.Query, warn: false

defmodule OldRepo do
  use Ecto.Repo,
      otp_app: :my_app,
      adapter: Ecto.Adapters.MyXQL,
      read_only: true  # Let's be safe, if we don't need to write.
end

#new_db_url = System.get_env("NEW_DB_URL") || raise("Missing NEW_DB_URL!")
# Use if running against a remote DB together with Catex.Users.
# If local database use Catex.Repo.
#defmodule NewRepo do
#  use Ecto.Repo,
#      otp_app: :catex,
#      adapter: Ecto.Adapters.Postgres,
#      read_only: false  # Let's be safe, if we don't need to write.
#end

# This bit is completely optional.
# You can skip it and do schemaless queries.
defmodule OldUser do
  use Ecto.Schema

  schema "users" do
    field :name, :string
    field :gender, :string
    field :zeusid, :integer
  end
end
defmodule OldRelation do
  use Ecto.Schema

  schema "relations" do
    field :from_id, :integer
    field :to_id, :integer
  end
end
defmodule OldRelationRequest do
  use Ecto.Schema

  schema "relation_requests" do
    field :from_id, :integer
    field :to_id, :integer
    field :status, :string # open, accepted, declined
  end
end

OldRepo.start_link(url: old_db_url, ssl: false)

# Verify it works, if you defined a schema.
IO.inspect count: OldRepo.aggregate(OldUser, :count)

# Seed users
for old_user <- OldRepo.all(OldUser) do
  count = Catex.Repo.aggregate(
    (from u in Catex.Users.User,
          where: u.zeus_id == ^old_user.zeusid),
    :count
  )
  if count == 0 do
    Catex.Users.create_user(%{name: old_user.name, zeus_id: old_user.zeusid, admin: false})
  end
end

for old_relation <- OldRepo.all(OldRelationRequest) do
  old_user_from = OldRepo.get(OldUser, old_relation.from_id)
  new_user_from = Catex.Repo.get_by(Catex.Users.User, zeus_id: old_user_from.zeusid)

  old_user_to = OldRepo.get(OldUser, old_relation.to_id)
  new_user_to = Catex.Repo.get_by(Catex.Users.User, zeus_id: old_user_to.zeusid)

  cond do
    old_relation.status == "accepted" ->
      Catex.Hugs.create_hug(
        %{
          initiator_id: new_user_from.id,
          participants: [
            %{status: :hug_confirmed, user_id: new_user_from.id},
            %{status: :hug_confirmed, user_id: new_user_to.id}
          ]
        }
      )
    old_relation.status == "open" ->
      Catex.Hugs.create_hug(
        %{
          initiator_id: new_user_from.id,
          participants: [
            %{status: :consent_given, user_id: new_user_from.id},
            %{status: :consent_pending, user_id: new_user_to.id}
          ]
        }
      )
    old_relation.status == "declined" ->
      Catex.Hugs.create_hug(
        %{
          initiator_id: new_user_from.id,
          participants: [
            %{status: :consent_given, user_id: new_user_from.id},
            %{status: :consent_denied, user_id: new_user_to.id}
          ]
        }
      )
  end
end