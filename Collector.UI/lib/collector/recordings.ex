defmodule Collector.Recordings do
  @moduledoc """
  The Recordings context.
  """

  import Ecto.Query, warn: false
  alias Collector.Repo
  alias Collector.Accounts.User
  alias Collector.Recordings.Source
  alias Collector.Recordings.Data

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
    from(s in Users)
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
    |> broadcast(:source_created)
  end

  def update_source(%Source{} = source, attrs) do
    source
    |> Source.changeset(attrs)
    |> Repo.update()
    |> broadcast(:source_updated)
  end

  def delete_source(%Source{} = source) do
    Repo.delete(source)
    |> broadcast(:source_deleted)
  end

  def change_source(%Source{} = source, attrs \\ %{}) do
    Source.changeset(source, attrs)
  end

  def list_data(source_id) do
    Data
    |> where([p], p.source_id == ^source_id)
    |> Repo.all
#    |> Enum.map(&{elem(NaiveDateTime.to_gregorian_seconds(&1.timestamp), 0),  elem(Integer.parse(&1.value), 0)})
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

  def subscribe do
    Phoenix.PubSub.subscribe(Collector.PubSub, "sources")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, source}, event) do
    Phoenix.PubSub.broadcast(Collector.PubSub, "sources", {event, source})
    {:ok, source}
  end
end
