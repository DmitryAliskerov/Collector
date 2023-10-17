defmodule Collector.SourceChanger do
  use GenServer

  import Ecto.Query, only: [from: 2]

  alias Collector.Recordings.Source
  alias Collector.Repo

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(args) do
    Phoenix.PubSub.subscribe(Collector.PubSub, "source_changer")

    {:ok, args}
  end

  defp notify_create_source(result, source) do
    Phoenix.PubSub.direct_broadcast(:"ui@127.0.0.1", Collector.PubSub, "change_source_answer", {:"create_source_#{result}", source})
  end

  defp notify_switch_source(result, source, new_enabled_state) do
    Phoenix.PubSub.direct_broadcast(:"ui@127.0.0.1", Collector.PubSub, "change_source_answer", {:"switch_source_#{result}", source, new_enabled_state})
  end

  defp notify_delete_source(result, source) do
    Phoenix.PubSub.direct_broadcast(:"ui@127.0.0.1", Collector.PubSub, "change_source_answer", {:"delete_source_#{result}", source})
  end

  @impl true
  def handle_info({:create_source, source}, socket) do
    IO.inspect "Create source. Source_id: #{source.id}"
    GenServer.cast(__MODULE__, {:create_source, source})

    {:noreply, socket}
  end


  @impl true
  def handle_info({:switch_source, source, new_enabled_state}, socket) do
    IO.inspect "Enable/Disable source. Source_id: #{source.id}"
    if new_enabled_state do
      GenServer.cast(__MODULE__, {:enable_source, source})
    else
      GenServer.cast(__MODULE__, {:disable_source, source})
    end

    {:noreply, socket}
  end

  def handle_info({:delete_source, source}, socket) do
    IO.inspect "Delete source. Source_id: #{source.id}"
    GenServer.cast(__MODULE__, {:delete_source, source})

    {:noreply, socket}
  end

  @impl true
  def handle_cast(operation, state) do
    case operation do
      {:create_source, source} -> create_source(source)
      {:enable_source, source} -> enable_source(source)
      {:disable_source, source} -> disable_source(source)
      {:delete_source, source} -> delete_source(source)
    end

    {:noreply, state}
  end

  defp create_source(source) do
    delay = Enum.random(500..1000)
    Process.sleep(delay)

    case source.type do
      "URL" ->
        case %{source_id: source.id, url: source.value, interval: source.interval, user_id: source.user_id}
             |> Collector.Worker.Ping.new()
             |> Oban.insert() do
          {:ok, _} -> IO.inspect "Oban job inserted."
                      notify_create_source(:ok, source)
          _ -> {:error, notify_create_source(:error, source)}
        end
      _ ->
        {:error, "Unknown source type: #{source.type}"}
    end
  end

  defp enable_source(source) do
    delay = Enum.random(500..1000)
    Process.sleep(delay)

    case source.type do
      "URL" ->
        case %{source_id: source.id, url: source.value, interval: source.interval, user_id: source.user_id}
             |> Collector.Worker.Ping.new()
             |> Oban.insert() do
          {:ok, _} -> IO.inspect "Oban job inserted."
                      notify_switch_source(:ok, source, true)
          _ -> {:error, notify_switch_source(:error, source, true)}
        end
      _ ->
        {:error, "Unknown source type: #{source.type}"}
    end
  end

  defp disable_source(source) do
    delay = Enum.random(500..1000)
    Process.sleep(delay)

    case source.type do
      "URL" ->
        args = %{url: source.value, interval: source.interval, source_id: source.id, user_id: source.user_id}

        jobs_query = from job in Oban.Job,
            where: job.worker == "Collector.Worker.Ping" and job.args == ^args and job.state == "scheduled",
            select: job

        case jobs_query |> Oban.cancel_all_jobs() do
          {:ok, counter} -> IO.inspect "Oban jobs canceled: #{counter}"
                            notify_switch_source(:ok, source, false)
          _ -> notify_switch_source(:error, source, false)
        end
      _ ->
        {:error, "Unknown source type: #{source.type}"}
    end
  end

  defp delete_source(source) do
    delay = Enum.random(500..1000)
    Process.sleep(delay)

    case source.type do
      "URL" ->
        args = %{url: source.value, interval: source.interval, source_id: source.id, user_id: source.user_id}

        jobs_query = from job in Oban.Job,
            where: job.worker == "Collector.Worker.Ping" and job.args == ^args and job.state == "scheduled",
            select: job

        case jobs_query |> Oban.cancel_all_jobs() do
          {:ok, counter} -> IO.inspect "Oban jobs canceled: #{counter}"
                            notify_delete_source(:ok, source)
          _ -> nil
        end
      _ ->
        {:error, "Unknown source type: #{source.type}"}
    end
  end
end