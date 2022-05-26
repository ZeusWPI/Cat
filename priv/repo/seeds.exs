# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Catex.Repo.insert!(%Catex.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

f = Catex.Repo.insert!(%Catex.Users.User{name: "flynn", zeus_id: 1, admin: true})
h = Catex.Repo.insert!(%Catex.Users.User{name: "hannah", zeus_id: 2, admin: false})
s = Catex.Repo.insert!(%Catex.Users.User{name: "sammy", zeus_id: 3, admin: false})

# Catex.Repo.insert!(%Catex.Hugs.Hug{participants: [f, h]})
