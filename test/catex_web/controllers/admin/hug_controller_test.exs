defmodule CatexWeb.HugControllerTest do
  use CatexWeb.ConnCase

  alias Catex.Hugs

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:hug) do
    {:ok, hug} = Hugs.create_hug(@create_attrs)
    hug
  end

  describe "index" do
    test "lists all hugs", %{conn: conn} do
      conn = get(conn, Routes.hug_path(conn, :index))
      assert html_response(conn, 200) =~ "Hugs"
    end
  end

  describe "new hug" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.hug_path(conn, :new))
      assert html_response(conn, 200) =~ "New Hug"
    end
  end

  describe "create hug" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.hug_path(conn, :create), hug: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.hug_path(conn, :show, id)

      conn = get(conn, Routes.hug_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Hug Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.hug_path(conn, :create), hug: @invalid_attrs
      assert html_response(conn, 200) =~ "New Hug"
    end
  end

  describe "edit hug" do
    setup [:create_hug]

    test "renders form for editing chosen hug", %{conn: conn, hug: hug} do
      conn = get(conn, Routes.hug_path(conn, :edit, hug))
      assert html_response(conn, 200) =~ "Edit Hug"
    end
  end

  describe "update hug" do
    setup [:create_hug]

    test "redirects when data is valid", %{conn: conn, hug: hug} do
      conn = put conn, Routes.hug_path(conn, :update, hug), hug: @update_attrs
      assert redirected_to(conn) == Routes.hug_path(conn, :show, hug)

      conn = get(conn, Routes.hug_path(conn, :show, hug))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, hug: hug} do
      conn = put conn, Routes.hug_path(conn, :update, hug), hug: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Hug"
    end
  end

  describe "delete hug" do
    setup [:create_hug]

    test "deletes chosen hug", %{conn: conn, hug: hug} do
      conn = delete(conn, Routes.hug_path(conn, :delete, hug))
      assert redirected_to(conn) == Routes.hug_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.hug_path(conn, :show, hug))
      end
    end
  end

  defp create_hug(_) do
    hug = fixture(:hug)
    {:ok, hug: hug}
  end
end
