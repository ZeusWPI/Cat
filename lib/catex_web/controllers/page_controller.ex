defmodule CatexWeb.PageController do
  use CatexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
