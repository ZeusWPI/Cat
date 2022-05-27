defmodule CatexWeb.PageController do
  @moduledoc false

  use CatexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
