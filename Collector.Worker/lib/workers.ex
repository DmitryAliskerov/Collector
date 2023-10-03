defmodule Collector.Workers do
 
  alias Collector.Recordings

  def run() do

    Recordings.oban_jobs_clear()

    for source <- Recordings.list_sources() do

      
    
      case source.type do
        "URL" ->
          %{source_id: source.id, url: source.value, interval: source.interval}
          |> Collector.Worker.Ping.new()
          |> Oban.insert()

          Process.sleep(2000)

          {:scheduled, "#{source.value} interval #{source.interval}"}
        _ ->
          {:skiped, "#{source.value} interval #{source.interval}"}
      end
    end
  end
end