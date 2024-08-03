defmodule Collector.Worker.Ping do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%{args: %{"source_id" => source_id, "url" => url, "interval" => interval, "user_id" => user_id}}) do

    %{source_id: source_id, url: url, interval: interval, user_id: user_id}
    |> new(schedule_in: interval)
    |> Oban.insert()

    with {:ok, result} <- perform(%{args: %{"url" => url}}) do
        timestamp = NaiveDateTime.utc_now()
        IO.inspect "Ping #{url} => Respone time: #{result} ms"

        Collector.Recordings.create_data(%{
          source_id: source_id,
          timestamp: timestamp,
          value: "#{result}"
        })

        Collector.ResultNotifier.cast_add_result(user_id, source_id)
    end

    :ok
  end

  def perform(%{args: %{"url" => url}}) do

    {:ok, Toolshed.tcping_result_ms(url) }
  end

end
