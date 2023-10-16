defmodule Collector.UpdateReceiver do
  use GenServer

  import Ecto.Query, only: [from: 2]

  alias Collector.Recordings.Source
  alias Collector.Repo

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def call_enable_source(source_id) do
     GenServer.call(__MODULE__, {:enable_source, source_id})
  end

  def call_disable_source(source_id) do
     GenServer.call(__MODULE__, {:disable_source, source_id})
  end

  @impl true
  def init(params) do
    {:ok, params}
  end

  @impl true
  def handle_call(operation, _, state) do
    case operation do
      {:enable_source, source_id} -> enable_source(source_id) |> IO.inspect
      {:disable_source, source_id} -> disable_source(source_id) |> IO.inspect
    end

    {:reply, state, state}
  end

  defp enable_source(id) do
    delay = Enum.random(50..200)
    Process.sleep(delay)

    source = Repo.get!(Source, id)

    case source.type do
      "URL" ->
        case %{source_id: source.id, url: source.value, interval: source.interval, user_id: source.user_id}
             |> Collector.Worker.Ping.new()
             |> Oban.insert() do
          {:ok, _} -> {:ok, "Source was enabled: #{source.id}. Oban job added."}
          _ -> {:error, "Source was not enabled."}
        end
      _ ->
        {:error, "Unknown source type: #{source.type}"}
    end
  end

  defp disable_source(id) do
    delay = Enum.random(50..200)
    Process.sleep(delay)

    source = Repo.get!(Source, id)

    case source.type do
      "URL" ->
        args = %{url: source.value, interval: source.interval, source_id: source.id, user_id: source.user_id}

        jobs_query = from job in Oban.Job,
            where: job.worker == "Collector.Worker.Ping" and job.args == ^args and job.state == "scheduled",
            select: job

        case jobs_query |> Oban.cancel_all_jobs() do
          {:ok, counter} -> {:ok, "Source was disabled: #{source.id}. Oban jobs canceled: #{counter}"}
          _ -> {:error, "Source was not disabled: #{source.id}"}
        end
      _ ->
        {:error, "Unknown source type: #{source.type}"}
    end
  end
end