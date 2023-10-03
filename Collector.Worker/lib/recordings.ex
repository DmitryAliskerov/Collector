defmodule Collector.Recordings do
  @moduledoc """
  The Recordings context.
  """

  import Ecto.Query, warn: false
  alias Collector.Repo
  alias Collector.Recordings.Data
  alias Collector.Recordings.Source

  def list_sources() do
    from(s in Source)
    |> Repo.all
  end

  def oban_jobs_clear() do
    Oban.Job
    |> Repo.delete_all
  end

  def create_data(attrs \\ %{}) do
    %Data{}
    |> Data.changeset(attrs)
    |> Repo.insert()
  end
end