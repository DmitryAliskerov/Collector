defmodule Collector.UpdatePusher do
  use GenServer
  use Task, restart: :transient

  @send_user_source_update_interval 2 * 1000

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
    Task.start_link(&send_user_source_update/0)
  end

  @impl true
  def init(interval) do
    table = :ets.new(:user_source_update, [:bag, :protected, :named_table])
    IO.inspect "ETS created: #{table}"

    {:ok, interval}
  end

  def cast_add_result(user_id, source_id) do
     GenServer.cast(__MODULE__, {:add_result, user_id, source_id})
  end

  @impl true
  def handle_cast(operation, state) do
    case operation do
      {:add_result, user_id, source_id} -> :ets.insert(:user_source_update, {user_id, source_id})
      {:send_result, user_source_update_raw} -> if Enum.member?(Node.list(), :"ui@127.0.0.1") do
						  user_sources_data = user_source_update_raw
					          |> Enum.group_by(fn {x, _} -> x end)
					          |> Enum.map(fn {x, y} -> {x, y |> Enum.reduce([], fn x, acc -> [elem(x, 1) | acc] end) } end)

						  :erpc.call(:"ui@127.0.0.1", Collector.UpdateReceiver, :update_user_sources, [user_sources_data])
						  IO.inspect "SEND user_sources_data: #{inspect user_sources_data}"
						else
						  IO.inspect "Cannot send update to :\"ui@127.0.0.1\". Node not in connected nodes: #{inspect Node.list()}"
						end
      _ -> {:stop, "Not implemented", state}
    end
    
    {:noreply, state}
  end

  @impl true
  def handle_call(:flush_results, _, state) do
    user_source_update_raw = :ets.match_object(:user_source_update, {:_, :_})
    if length(user_source_update_raw) != 0 do
      GenServer.cast(__MODULE__, {:send_result, user_source_update_raw})    
      :ets.match_delete(:user_source_update, {:_, :_})
    end

    {:reply, state, state}
  end

  defp send_user_source_update() do
    receive do
      after
        @send_user_source_update_interval ->
          GenServer.call(__MODULE__, :flush_results)

          send_user_source_update()
    end
  end
end