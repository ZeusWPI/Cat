defmodule Catex.Authenticator do
  @moduledoc false

  import Plug.Conn

  alias Catex.Users

  def init(opts), do: opts

  def call(conn, _opts) do
    user =
      conn
      |> get_session(:user_id)
      |> case do
           nil -> nil
           id -> Users.get_user(id)
                 |> case do
                      nil -> nil
                      user -> user
                    end
         end
    assign(conn, :current_user, user)
  end

end
