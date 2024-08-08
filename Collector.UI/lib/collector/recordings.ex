defmodule Collector.Recordings do
  @moduledoc """
  The Recordings context.
  """

  import Ecto.Query, warn: false
  alias Collector.Repo
  alias Collector.Accounts.User
  alias Collector.Recordings.Source
  alias Collector.Recordings.Data

  def clear_jobs() do
    query = "delete from oban_jobs; delete from sqlite_sequence where name='oban_jobs';"
    Ecto.Adapters.SQL.query!(Repo, query, [])
  end

  def clear_users() do
    query = "delete from users; delete from sqlite_sequence where name='users';"
    Ecto.Adapters.SQL.query!(Repo, query, [])
  end

  def clear_sources() do
    query = "delete from sources; delete from sqlite_sequence where name='sources';"
    Ecto.Adapters.SQL.query!(Repo, query, [])
  end

  def clear_data() do
    query = "delete from data; delete from sqlite_sequence where name='data';"
    Ecto.Adapters.SQL.query!(Repo, query, [])
  end

  def list_users() do
    from(s in User)
    |> Repo.all
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end
  
  def list_sources(user_id) do
    from(s in Source, where: s.user_id == ^user_id, order_by: [s.id])
    |> Repo.all
  end

  def get_source!(id), do: Repo.get!(Source, id)

  def create_source(attrs \\ %{}) do
    %Source{}
    |> Source.changeset(attrs)
    |> Repo.insert()
  end

  def create_source_n(attrs \\ %{}, n) do
    Enum.each(0..n, fn(_x) ->
      %Source{}
      |> Source.changeset(attrs)
      |> Repo.insert()
    end)
  end

  def update_source(%Source{} = source, attrs) do
    source
    |> Source.changeset(attrs)
    |> Repo.update()
  end

  def delete_source(%Source{} = source) do
    Repo.delete(source)
  end

  def change_source(%Source{} = source, attrs \\ %{}) do
    Source.changeset(source, attrs)
  end

  def list_data(source_id) do
    six_hours_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(-60 * 60 * 6)
    with xs = [_|_] <- Data |> where([p], p.source_id == ^source_id and p.timestamp > ^six_hours_ago) |> Repo.all do xs else _ -> [%{timestamp: NaiveDateTime.utc_now(), value: "0"}] end
    |> Enum.map(&{&1.timestamp,  elem(Integer.parse(&1.value), 0)})
  end

  def create_data(attrs \\ %{}) do
    %Data{}
    |> Data.changeset(attrs)
    |> Repo.insert()
  end

  def change_data(%Data{} = data, attrs \\ %{}) do
    Data.changeset(data, attrs)
  end
end
