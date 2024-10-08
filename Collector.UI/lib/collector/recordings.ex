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
    query = "TRUNCATE TABLE oban_jobs RESTART IDENTITY CASCADE"
    Ecto.Adapters.SQL.query!(Repo, query, [])
  end

  def clear_users() do
    query = "TRUNCATE TABLE users RESTART IDENTITY CASCADE"
    Ecto.Adapters.SQL.query!(Repo, query, [])
  end

  def clear_sources() do
    query = "TRUNCATE TABLE sources RESTART IDENTITY CASCADE"
    Ecto.Adapters.SQL.query!(Repo, query, [])
  end

  def clear_data() do
    query = "TRUNCATE TABLE data RESTART IDENTITY CASCADE"
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
    with xs = [_|_] <- Data |> where([p], p.source_id == ^source_id) |> Repo.all do xs else _ -> [%{timestamp: NaiveDateTime.utc_now(), value: "0"}] end  
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
