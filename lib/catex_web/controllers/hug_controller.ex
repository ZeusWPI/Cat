defmodule CatexWeb.HugController do
  @moduledoc false

  use CatexWeb, :controller

  alias Catex.Hugs
  alias Catex.Users
  alias Catex.Hugs.Hug

  alias CatexWeb.Utils.Combination

  def index(conn, _params) do
    hugs = Hugs.list_hugs_completed()
    #    Enum.map(hugs, fn h -> %{index: h.id, name: ""} end)
    json(
      conn,
      %{
        nodes:
          Users.list_users()
          |> Enum.map(fn u -> %{index: u.id, name: u.name} end),
        links:
          Enum.flat_map(
            hugs,
            &(Combination.combine(&1.participants, 2)
              |> Enum.map(fn [a, b] -> %{source: a.user_id, target: b.user_id} end))
          )
      }
    )
  end
end
