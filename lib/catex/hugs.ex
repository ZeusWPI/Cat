defmodule Catex.Hugs do
  @moduledoc """
  The Hugs context.

  A request to get a hug would start at pending and wants everyone to give consent
  A request to document/record a hug starts at hug_pending

  CASE 1 : Requests a hug with success
    a requests hug to b                 [a: consent_given, b: consent_pending]
    Other person gives consent          [a: consent_given, b: consent_given]
    They enact in a hug, b confirms     [a: consent_given, b: hug_confirmed]
    a confirms                          [a: hug_confirmed, b: hug_confirmed]
    Hug is now successfully recorded

  CASE 2 : Requests a hug but consent is not given
    a requests hug to b                 [a: consent_given, b: consent_pending]
    Other person denies consent         [a: consent_given, b: consent_denied]
    Hug can not be continued. Confirms are not possible when consent is denied or not given.
    If a participant does confirm the hug the administration will be contacted to provide
      the victim with adequate support.

  CASE 3 : Tries to record a hug,  success
    a confirms previous hug with b      [a: hug_confirmed, b: hug_pending]
    Other person confirms action        [a: hug_confirmed, b: hug_confirmed]
     Hug is now successfully recorded

  CASE 4 : Tries to record a hug,  denied
    a confirms previous hug with b      [a: hug_confirmed, b: hug_pending]
    Other person denies event           [a: hug_confirmed, b: hug_denied]
     Hug is now not recorded.
     We see this as a probable administrative error. Consent was not specifically denied.
     The action is just not confirmed by the other party.
  """

  import Ecto.Query, warn: false
  alias Catex.Repo

  alias Catex.Hugs.Hug
  alias Catex.Hugs.HugParticipant

  def status_flow do
    %{
      consent_pending: [
        {"Give consent for a hug", "consent_given"},
        {"Don't give consent for a hug", "consent_denied"}
      ],
      consent_given: [
        {"Revoke your consent", "consent_denied"},
        {"Confirm that a hug took place", "hug_confirmed"},
        {"Deny that a hug happened or will happen", "hug_denied"}
      ],
      consent_denied: [
        {"Do give consent for a hug", "consent_given"}
      ],
      hug_pending: [
        {"Confirm that a hug took place", "hug_confirmed"},
        {"Deny that a hug happened or will happen", "hug_denied"}
      ],
      hug_confirmed: [],
      hug_denied: []
    }
  end

  @doc """
  Returns the list of hugs.

  ## Examples

      iex> list_hugs()
      [%Hug{}, ...]

  """
  def list_hugs do
    Repo.all(
      from h in Hug,
      join: hp in assoc(h, :participants),
      join: user in assoc(hp, :user),
      preload: [
        participants: [:user]
      ]
    )
  end

  @doc """
  Returns the list of hugs that have the given user as a participant.
  """
  def list_hugs_from_user(from_user_id) do
    #    Repo.all(
    #      from h in Hug,
    #      join: hp in assoc(h, :participants),
    #      join: user in assoc(hp, :user),
    #      where: ^from_user.id in subquery(
    #
    #      ),
    #      preload: [
    #        participants: [:user]
    #      ]
    #    )
    from_user_hugs = from p in HugParticipant,
                          join: user in assoc(p, :user),
                          join: hug in assoc(p, :hug),
                          where: user.id == ^from_user_id,
                          select: hug.id

    Repo.all(
      from h in Hug,
      where: h.id in subquery(from_user_hugs),
      preload: [
        participants: [:user]
      ]
    )
  end

  defp participants_unconfirmed() do
    from(
      HugParticipant
      |> where([hp], hp.status != :hug_confirmed)
      |> select([hp], hp.hug_id)
    )
  end

  # N+1 query -> worries for later
  def list_hugs_completed do
    Repo.all(
      from h in Hug,
      join: hp in assoc(h, :participants),
      where: h.id not in subquery(participants_unconfirmed()),
      preload: [
        participants: hp
      ]
    )
  end

  @doc """
  Gets a single hug.

  Raises `Ecto.NoResultsError` if the Hug does not exist.

  ## Examples

      iex> get_hug!(123)
      %Hug{}

      iex> get_hug!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hug!(id) do
    Repo.one!(
      from h in Hug,
      where: h.id == ^id,
      preload: [
        participants: [:user]
      ]
    )
  end

  @doc """
  Creates a hug.

  ## Examples

      iex> create_hug(%{field: value})
      {:ok, %Hug{}}

      iex> create_hug(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hug(attrs \\ %{}) do
    %Hug{}
    |> Hug.changeset(attrs)
    |> PaperTrail.insert()

    #    multi =
    #      Ecto.Multi.new()
    #      |> Ecto.Multi.insert(:hug, hug)
    #
    #    multi
    #    |> Ecto.Multi.merge(
    #         fn %{hug: hug} ->
    #           Ecto.Multi.new()
    #           |> Ecto.Multi.insert(:participants, Ecto.build_assoc(hug, :participants))
    #         end
    #       )
    #    |> Catex.Repo.transaction()
  end

  @doc """
  Updates a hug.

  ## Examples

      iex> update_hug(hug, %{field: new_value})
      {:ok, %Hug{}}

      iex> update_hug(hug, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hug(%Hug{} = hug, attrs) do
    hug
    |> Hug.changeset(attrs)
    |> PaperTrail.update()
  end

  @doc """
  Deletes a hug.

  ## Examples

      iex> delete_hug(hug)
      {:ok, %Hug{}}

      iex> delete_hug(hug)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hug(%Hug{} = hug) do
    Repo.delete_all(
      from p in HugParticipant,
      where: p.hug_id == ^hug.id
    )
    PaperTrail.delete(hug)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hug changes.

  ## Examples

      iex> change_hug(hug)
      %Ecto.Changeset{data: %Hug{}}

  """
  def change_hug(%Hug{} = hug, attrs \\ %{}) do
    Hug.changeset(hug, attrs)
  end

  import Torch.Helpers, only: [sort: 1, paginate: 4, strip_unset_booleans: 3]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of hugs using filtrex
  filters.

  ## Examples

      iex> paginate_hugs(%{})
      %{hugs: [%Hug{}], ...}

  """
  @spec paginate_hugs(map) :: {:ok, map} | {:error, any}
  def paginate_hugs(params \\ %{}) do
    params =
      params
      |> strip_unset_booleans("hug", [])
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:hugs), params["hug"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_hugs(filter, params) do
      {
        :ok,
        %{
          hugs: page.entries,
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

  defp do_paginate_hugs(filter, params) do
    Hug
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> join(:left, [hug], participants in assoc(hug, :participants))
    |> join(:left, [hug, participants], user in assoc(participants, :user))
    |> preload(
         [hug, participants, user],
         participants: {
           participants,
           user: user
         }
       )
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:hugs) do
    defconfig do
      number :initiator_id
    end
  end
end
