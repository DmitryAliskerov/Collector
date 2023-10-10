defmodule Collector.Workers do

  use GenServer
  use Task, restart: :transient
 
  import Ecto.Query, only: [from: 2]

  alias Collector.Recordings
  alias Collector.Recordings.Source
  alias Collector.Repo

  @send_user_source_update_interval 5 * 1000

  def cast_add_result(user_id, source_id) do
     GenServer.cast(__MODULE__, {:add_result, user_id, source_id})
  end

  def call_enable_source(source_id) do
     GenServer.call(__MODULE__, {:enable_source, source_id})
  end

  def call_disable_source(source_id) do
     GenServer.call(__MODULE__, {:disable_source, source_id})
  end

  def handle_cast(operation, state) do
    case operation do
      {:add_result, user_id, source_id} -> :ets.insert(:user_source_update, {user_id, source_id})
      {:send_result, user_source_update_raw} -> user_source_update = user_source_update_raw
					    |> Enum.group_by(fn {x, _} -> x end)
					    |> Enum.map(fn {x, y} -> {x, y |> Enum.reduce([], fn x, acc -> [elem(x, 1) | acc] end) } end)
					    IO.inspect "SEND user_source_update: #{inspect user_source_update}"
      					    task = Task.async(fn -> :erpc.call(:"ui@127.0.0.1", CollectorWeb.Endpoint, :update_user_sources, [user_source_update]) end)
					    Task.await(task)
      _ -> {:stop, "Not implemented", state}
    end
    
    {:noreply, state}
  end

  def handle_call(operation, _, state) do
    case operation do
      {:enable_source, source_id} -> enable_source(source_id) |> IO.inspect
      {:disable_source, source_id} -> disable_source(source_id) |> IO.inspect
      :flush_results -> user_source_update_raw = :ets.match_object(:user_source_update, {:_, :_})
                        if length(user_source_update_raw) != 0 do
                          GenServer.cast(__MODULE__, {:send_result, user_source_update_raw})    
                          :ets.match_delete(:user_source_update, {:_, :_})
                        end
    end

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

  defp send_user_source_update() do
    receive do
      after
        @send_user_source_update_interval ->
          GenServer.call(__MODULE__, :flush_results)

          send_user_source_update()
    end
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

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
    Task.start_link(&send_user_source_update/0)
  end

end