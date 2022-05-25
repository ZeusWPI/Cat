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

  @doc """
  Returns the list of hugs.

  ## Examples

      iex> list_hugs()
      [%Hug{}, ...]

  """
  def list_hugs do
    Repo.all(Hug)
  end

  defp participants_unconfirmed() do
    from HugParticipant
         |> where([hp], hp.status != :hug_confirmed)
         |> select([hp], hp.hug_id)
  end

  # N+1 query -> worries for later
  def list_hugs_completed do
    Repo.all from h in Hug,
             join: hp in assoc(h, :hug_participants),
             where: h.id not in subquery(participants_unconfirmed),
             preload: [
               hug_participants: hp
             ]
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
  def get_hug!(id), do: Repo.get!(Hug, id)

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
    |> Repo.insert()
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
    |> Repo.update()
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
    Repo.delete(hug)
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
end
