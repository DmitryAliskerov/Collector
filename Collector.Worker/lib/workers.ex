defmodule Collector.Workers do
 
  import Ecto.Query, only: [from: 2]

  alias Collector.Recordings
  alias Collector.Recordings.Source
  alias Collector.Repo

  def enable_source(id) do
    delay = Enum.random(50..200)
    Process.sleep(delay)

    source = Repo.get!(Source, id)

    case source.type do
      "URL" ->
        case %{source_id: source.id, url: source.value, interval: source.interval}
             |> Collector.Worker.Ping.new()
             |> Oban.insert() do
          {:ok, _} -> {:ok, "Source was enabled."} 
          _ -> {:error, "Source was not enabled."}
        end
      _ ->
        {:error, "Unknown source type: #{source.type}"}
    end
  end

  def disable_source(id) do
    delay = Enum.random(50..200)
    Process.sleep(delay)

    source = Repo.get!(Source, id)

    case source.type do
      "URL" ->
        args = %{url: source.value, interval: source.interval, source_id: source.id}

        jobs_query = from job in Oban.Job,
            where: job.worker == "Collector.Worker.Ping" and job.args == ^args and job.state == "scheduled",
            select: job

        case jobs_query |> Oban.cancel_all_jobs() do
          {:ok, _} -> {:ok, "Source was disabled: #{source.id}"}
          _ -> {:error, "Source was not disabled: #{source.id}"}
        end
      _ ->
        {:error, "Unknown source type: #{source.type}"}
    end
  end

  def run() do

    Recordings.oban_jobs_clear()

    for source <- Recordings.list_sources() do

      case source.type do
        "URL" ->
          if source.enabled do
            %{source_id: source.id, url: source.value, interval: source.interval}
            |> Collector.Worker.Ping.new()
            |> Oban.insert()

            IO.inspect "runned: id: #{source.id} - #{source.value} interval #{source.interval}"
          else
            IO.inspect "skipped: id: #{source.id} - #{source.value} interval #{source.interval} enabled: false"
          end
        _ ->
          IO.inspect "skipped: id: #{source.id} - unknown source type: #{source.type}"
      end
    end

  end

end