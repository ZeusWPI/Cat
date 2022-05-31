defmodule CatexWeb.HugLiveTest do
  use CatexWeb.ConnCase

  import Phoenix.LiveViewTest
  import Catex.HugsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_hug(_) do
    hug = hug_fixture()
    %{hug: hug}
  end

  describe "Index" do
    setup [:create_hug]

    test "lists all hugs", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.hug_index_path(conn, :index))

      assert html =~ "Listing Hugs"
    end

    test "saves new hug", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.hug_index_path(conn, :index))

      assert index_live |> element("a", "New Hug") |> render_click() =~
               "New Hug"

      assert_patch(index_live, Routes.hug_index_path(conn, :new))

      assert index_live
             |> form("#hug-form", hug: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#hug-form", hug: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.hug_index_path(conn, :index))

      assert html =~ "Hug created successfully"
    end

    test "updates hug in listing", %{conn: conn, hug: hug} do
      {:ok, index_live, _html} = live(conn, Routes.hug_index_path(conn, :index))

      assert index_live |> element("#hug-#{hug.id} a", "Edit") |> render_click() =~
               "Edit Hug"

      assert_patch(index_live, Routes.hug_index_path(conn, :edit, hug))

      assert index_live
             |> form("#hug-form", hug: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#hug-form", hug: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.hug_index_path(conn, :index))

      assert html =~ "Hug updated successfully"
    end

    test "deletes hug in listing", %{conn: conn, hug: hug} do
      {:ok, index_live, _html} = live(conn, Routes.hug_index_path(conn, :index))

      assert index_live |> element("#hug-#{hug.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#hug-#{hug.id}")
    end
  end

  describe "Show" do
    setup [:create_hug]

    test "displays hug", %{conn: conn, hug: hug} do
      {:ok, _show_live, html} = live(conn, Routes.hug_show_path(conn, :show, hug))

      assert html =~ "Show Hug"
    end

    test "updates hug within modal", %{conn: conn, hug: hug} do
      {:ok, show_live, _html} = live(conn, Routes.hug_show_path(conn, :show, hug))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Hug"

      assert_patch(show_live, Routes.hug_show_path(conn, :edit, hug))

      assert show_live
             |> form("#hug-form", hug: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#hug-form", hug: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.hug_show_path(conn, :show, hug))

      assert html =~ "Hug updated successfully"
    end
  end
end
