defmodule CatexWeb.Admin.HugController do
  @moduledoc false

  use CatexWeb, :controller

  alias Catex.Hugs
  alias Catex.Hugs.Hug

  plug(:put_root_layout, {CatexWeb.LayoutView, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case Hugs.paginate_hugs(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Hugs. #{inspect(error)}")
        |> redirect(to: Routes.admin_hug_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Hugs.change_hug(%Hug{})
    render(conn, "new.html", changeset: changeset)
  end

  # %{"hug" => hug_params}
  def create(conn, hug_params) do
    case Hugs.create_hug(hug_params) do
      {:ok, %{model: hug}} ->
        conn
        |> put_flash(:info, "Hug created successfully.")
        |> redirect(to: Routes.admin_hug_path(conn, :show, hug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    hug = Hugs.get_hug!(id)
    render(conn, "show.html", hug: hug)
  end

  def edit(conn, %{"id" => id}) do
    hug = Hugs.get_hug!(id)
    changeset = Hugs.change_hug(hug)
    render(conn, "edit.html", hug: hug, changeset: changeset)
  end

  # %{"id" => id, "hug" => hug_params}
  def update(conn, hug_params) do
    hug = Hugs.get_hug!(hug_params["id"])

    case Hugs.update_hug(hug, hug_params) do
      {:ok, %{model: hug}} ->
        conn
        |> put_flash(:info, "Hug updated successfully.")
        |> redirect(to: Routes.admin_hug_path(conn, :show, hug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", hug: hug, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    hug = Hugs.get_hug!(id)
    {:ok, _hug} = Hugs.delete_hug(hug)

    conn
    |> put_flash(:info, "Hug deleted successfully.")
    |> redirect(to: Routes.admin_hug_path(conn, :index))
  end
end
