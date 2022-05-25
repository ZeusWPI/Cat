defmodule Catex.HugsTest do
  use Catex.DataCase

  alias Catex.Hugs

  alias Catex.Hugs.Hug

  @valid_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "#paginate_hugs/1" do
    test "returns paginated list of hugs" do
      for _ <- 1..20 do
        hug_fixture()
      end

      {:ok, %{hugs: hugs} = page} = Hugs.paginate_hugs(%{})

      assert length(hugs) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_hugs/0" do
    test "returns all hugs" do
      hug = hug_fixture()
      assert Hugs.list_hugs() == [hug]
    end
  end

  describe "#get_hug!/1" do
    test "returns the hug with given id" do
      hug = hug_fixture()
      assert Hugs.get_hug!(hug.id) == hug
    end
  end

  describe "#create_hug/1" do
    test "with valid data creates a hug" do
      assert {:ok, %Hug{} = hug} = Hugs.create_hug(@valid_attrs)
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hugs.create_hug(@invalid_attrs)
    end
  end

  describe "#update_hug/2" do
    test "with valid data updates the hug" do
      hug = hug_fixture()
      assert {:ok, hug} = Hugs.update_hug(hug, @update_attrs)
      assert %Hug{} = hug
    end

    test "with invalid data returns error changeset" do
      hug = hug_fixture()
      assert {:error, %Ecto.Changeset{}} = Hugs.update_hug(hug, @invalid_attrs)
      assert hug == Hugs.get_hug!(hug.id)
    end
  end

  describe "#delete_hug/1" do
    test "deletes the hug" do
      hug = hug_fixture()
      assert {:ok, %Hug{}} = Hugs.delete_hug(hug)
      assert_raise Ecto.NoResultsError, fn -> Hugs.get_hug!(hug.id) end
    end
  end

  describe "#change_hug/1" do
    test "returns a hug changeset" do
      hug = hug_fixture()
      assert %Ecto.Changeset{} = Hugs.change_hug(hug)
    end
  end

  def hug_fixture(attrs \\ %{}) do
    {:ok, hug} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Hugs.create_hug()

    hug
  end

end
