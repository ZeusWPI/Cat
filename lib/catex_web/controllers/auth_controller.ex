defmodule CatexWeb.AuthController do
  use CatexWeb, :controller
  @moduledoc false

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode
  alias OAuth2.AccessToken
  alias Poison.Parser

  alias Catex.Users

  @client OAuth2.Client.new(
            [
              strategy: OAuth2.Strategy.AuthCode, #default
              client_id: "tomtest",
              client_secret: "blargh",
              site: "https://adams.ugent.be",
              redirect_uri: "http://localhost:4000/auth/callback",
              token_url: "https://adams.ugent.be/oauth/oauth2/token"
            ]
          )
          |> OAuth2.Client.put_serializer("application/json", Jason)


  def login(conn, _params) do
    redirect(conn, external: OAuth2.Client.authorize_url!(@client))
  end

  def callback(conn, %{"code" => code})do
    client = OAuth2.Client.get_token!(@client, code: code)
    resource = OAuth2.Client.get!(client, "/oauth/api/current_user").body
    match = Users.get_user_by_zeus_id(resource["id"])
    if match == [] do
      Users.create_user(
        %{
          zeus_id: resource["id"],
          admin: false,
          name: resource["username"],
          access_token: client.token.access_token,
          refresh_token: client.token.refresh_token
        }
      )
    else
      Users.update_user_tokens(hd(match), client.token.access_token, client.token.refresh_token)
    end
    redirect(conn, to: "/")
  end

end
