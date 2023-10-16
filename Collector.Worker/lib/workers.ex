defmodule Collector.Workers do

  use GenServer

  alias Collector.Recordings
 
  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  @impl true
  def init(args) do
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
end