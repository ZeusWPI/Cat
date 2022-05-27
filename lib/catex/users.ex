defmodule Catex.Users do
  @moduledoc """
  The Users context.
  """
  import Torch.Helpers, only: [sort: 1, paginate: 4, strip_unset_booleans: 3]
  import Filtrex.Type.Config

  alias PaperTrail

  import Ecto.Query, warn: false
  alias Catex.Repo

  alias Catex.Users.User

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of users using filtrex
  filters.
  ## Examples
      iex> paginate_users(%{})
      %{users: [%User{}], ...}
  """
  @spec paginate_users(map) :: {:ok, map} | {:error, any}
  def paginate_users(params \\ %{}) do
    params =
      params
      #      |> strip_unset_booleans("user", [<%= Enum.reduce(schema.attrs, [], &(if elem(&1, 1) == :boolean, do: [inspect(elem(&1, 0)) | &2], else: &2)) %>])
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:users), params["user"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_users(filter, params) do
      {
        :ok,
        %{
          users: page.entries,
          page_number: page.page_number,
          page_size: page.page_size,
          total_pages: page.total_pages,
          total_entries: page.total_entries,
          distance: @pagination_distance,
          sort_field: sort_field,
          sort_direction: sort_direction
        }
      }
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_users(filter, params) do
    User
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of users.
  ## Examples
      iex> list_users()
      [%User{}, ...]
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.
  Raises `Ecto.NoResultsError` if the <%= schema.human_singular %> does not exist.
  ## Examples
      iex> get_user!(123)
      %User{}
      iex> get_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)

  def get_user_by_zeus_id(zeus_id) do
    User
    |> where([u], u.zeus_id == ^zeus_id)
    |> Repo.one()
  end

  @doc """
  Creates a user.
  ## Examples
      iex> create_user(%{field: value})
      {:ok, %User{}}
      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> PaperTrail.insert()
  end

  @doc """
  Updates a user.
  ## Examples
      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}
      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> PaperTrail.update()
  end

  def update_user_tokens(%User{} = user, access_token, refresh_token) do
    user
    |> User.changeset(%{access_token: access_token, refresh_token: refresh_token})
    |> Repo.update()
  end

  @doc """
  Deletes a User.
  ## Examples
      iex> delete_user(user)
      {:ok, %User{}}
      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}
  """
  def delete_user(%User{} = user) do
    PaperTrail.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  ## Examples
      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  defp filter_config(:users) do
    defconfig do
      text(:name)
      text(:zeus_id)
      text(:admin)
      #      <%= for {name, type} <- schema.attrs do %><%= cond do %>
      #        <% type in [:string, :text] -> %>text <%= inspect name %>
      #        <% type in [:integer, :number] -> %>number <%= inspect name %>
      #        <% type in [:naive_datetime, :utc_datetime, :datetime, :date] -> %>date <%= inspect name %>
      #        <% type in [:boolean] -> %>boolean <%= inspect name %>
      #        <% true -> %>
      #      <% end %><% end %>
    end
  end

  #
  #  def paginate_users(params) do
  #    {
  #      :ok,
  #      User
  #      #    |> order_by(^Torch.Helpers.sort(params))
  #      |> Torch.Helpers.paginate(Repo, params, @pagination)
  #    }
  #  end
end
