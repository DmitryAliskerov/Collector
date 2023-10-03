defmodule Collector.Worker.Ping do
  use Oban.Worker

  @impl true
  def perform(%{args: %{"source_id" => source_id, "url" => url, "interval" => interval}}) do

    %{source_id: source_id, url: url, interval: interval}
    |> new(schedule_in: interval)
    |> Oban.insert()

    with {:ok, result} <- perform(%{args: %{"url" => url}}) do
        timestamp = NaiveDateTime.utc_now()
        IO.inspect "Ping #{url} => Respone time: #{result}"

        Collector.Recordings.create_data(%{
          source_id: source_id,
          timestamp: timestamp,
          value: "#{result}"
        })

        #IO.inspect "Record inserted."
    end

    :ok
  end

  def perform(%{args: %{"url" => url}}) do
    ping(url)
  end

  defp ping(url) do
    #IO.inspect "Emulate ping: #{url}"
    #delay = Enum.random(1000..2000)
    #Process.sleep(delay)

    response_time = Toolshed.tcping_once url
    
    #IO.inspect "time: #{response_time}"

    {:ok, response_time}
  end
end
