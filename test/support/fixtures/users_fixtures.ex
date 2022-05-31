defmodule Catex.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Catex.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        gender: "some gender",
        name: "some name"
      })
      |> Catex.Users.create_user()

    user
  end
end
