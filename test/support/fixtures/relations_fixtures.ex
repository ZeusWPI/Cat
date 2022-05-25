defmodule Catex.HugsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Catex.Hugs` context.
  """

  @doc """
  Generate a hug.
  """
  def hug_fixture(attrs \\ %{}) do
    {:ok, hug} =
      attrs
      |> Enum.into(%{})
      |> Catex.Hugs.create_hug()

    hug
  end
end
