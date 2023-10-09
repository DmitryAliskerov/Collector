defmodule Collector.Workers do

  use GenServer
 
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

  def add_result(user_id, source_id) do
     GenServer.cast(__MODULE__, {:add_result, user_id, source_id})
  end

  def flush_results() do
     GenServer.call(__MODULE__, :flush_results)
  end

  def handle_cast(operation, state) do
    case operation do
      {:add_result, user_id, source_id} -> :ets.insert(:user_source_update, {user_id, source_id})
      {:send_result, user_source_update} -> IO.inspect "SEND user_source_update: #{inspect user_source_update}"
      _ -> {:stop, "Not implemented", state}
    end
    
    {:noreply, state}
  end

  def handle_call(:flush_results, _, state) do
    user_source_update = :ets.match_object(:user_source_update, {:_, :_})
    |> Enum.group_by(fn {x, _} -> x end)
    |> Enum.map(fn {x, y} -> {x, y |> Enum.reduce([], fn x, acc -> [elem(x, 1) | acc] end) } end)
    |> IO.inspect

    GenServer.cast(__MODULE__, {:send_result, user_source_update})    

    :ets.match_delete(:user_source_update, {:_, :_})

    {:reply, state, state}
  end

  @impl true
  def init(args) do
   table = :ets.new(:user_source_update, [:bag, :protected, :named_table])
   IO.inspect "ETS created: #{table}"

   Recordings.oban_jobs_clear()

    for source <- Recordings.list_sources() do

      case source.type do
        "URL" ->
          if source.enabled do
            %{source_id: source.id, url: source.value, interval: source.interval, user_id: source.user_id}
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

    {:ok, args}
  end

  def start_link(initial_value) do
    GenServer.start(__MODULE__, initial_value, name: __MODULE__)
  end

end