defmodule Catex.HugsTest do
  use Catex.DataCase

  alias Catex.Hugs

  describe "hugs" do
    alias Catex.Hugs.Hug

    import Catex.HugsFixtures

    @invalid_attrs %{}

    test "list_hugs/0 returns all hugs" do
      hug = hug_fixture()
      assert Hugs.list_hugs() == [hug]
    end

    test "get_hug!/1 returns the hug with given id" do
      hug = hug_fixture()
      assert Hugs.get_hug!(hug.id) == hug
    end

    test "create_hug/1 with valid data creates a hug" do
      valid_attrs = %{}

      assert {:ok, %Hug{} = hug} = Hugs.create_hug(valid_attrs)
    end

    test "create_hug/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hugs.create_hug(@invalid_attrs)
    end

    test "update_hug/2 with valid data updates the hug" do
      hug = hug_fixture()
      update_attrs = %{}

      assert {:ok, %Hug{} = hug} = Hugs.update_hug(hug, update_attrs)
    end

    test "update_hug/2 with invalid data returns error changeset" do
      hug = hug_fixture()
      assert {:error, %Ecto.Changeset{}} = Hugs.update_hug(hug, @invalid_attrs)
      assert hug == Hugs.get_hug!(hug.id)
    end

    test "delete_hug/1 deletes the hug" do
      hug = hug_fixture()
      assert {:ok, %Hug{}} = Hugs.delete_hug(hug)
      assert_raise Ecto.NoResultsError, fn -> Hugs.get_hug!(hug.id) end
    end

    test "change_hug/1 returns a hug changeset" do
      hug = hug_fixture()
      assert %Ecto.Changeset{} = Hugs.change_hug(hug)
    end
  end
end
