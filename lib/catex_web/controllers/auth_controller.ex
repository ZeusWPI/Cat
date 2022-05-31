defmodule CatexWeb.AuthController do
  @moduledoc false

  use CatexWeb, :controller

  alias Catex.Users
  alias Application

  @client OAuth2.Client.new(
            # default
            strategy: OAuth2.Strategy.AuthCode,
            client_id: Application.get_env(:catex, :oauth2_client_id),
            client_secret: Application.get_env(:catex, :oauth2_client_secret),
            site: "https://adams.ugent.be",
            redirect_uri: "#{Application.get_env(:catex, :oauth2_app_url)}/auth/callback",
            token_url: "https://adams.ugent.be/oauth/oauth2/token"
          )
          |> OAuth2.Client.put_serializer("application/json", Jason)

  def login(conn, _params) do
    IO.inspect(@client)
    IO.inspect(@client.client_id)
    redirect(conn, external: OAuth2.Client.authorize_url!(@client))
  end

  def logout(conn, _params) do
    put_session(conn, :user_id, nil)
    |> redirect(to: "/")
  end

  def callback(conn, %{"code" => code}) do
    client = OAuth2.Client.get_token!(@client, code: code)
    resource = OAuth2.Client.get!(client, "/oauth/api/current_user").body
    user = Users.get_user_by_zeus_id(resource["id"])

    if user == nil do
      Users.create_user(
        %{
          name: resource["username"],
          zeus_id: resource["id"],
          admin: false,
          access_token: client.token.access_token,
          refresh_token: client.token.refresh_token
        }
      )
    else
      Users.update_user_tokens(user, client.token.access_token, client.token.refresh_token)
    end

    u = Users.get_user_by_zeus_id(resource["id"])

    put_session(conn, :user_id, u.id)
    |> redirect(to: "/")
  end
end
