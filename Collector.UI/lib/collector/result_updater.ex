defmodule Collector.ResultUpdater do
  use GenServer

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(params) do
    Phoenix.PubSub.subscribe(Collector.PubSub, "result_notifier")

    {:ok, params}
  end

  @impl true
  def handle_info({:updated_user_sources, user_sources_data}, socket) do
    update_user_sources(user_sources_data)

    {:noreply, socket}
  end

  def update_user_sources(user_sources_data) do
    GenServer.cast(__MODULE__, {:update_user_sources, user_sources_data})
  end

  @impl true
  def handle_cast({:update_user_sources, user_sources_data}, state) do
    IO.inspect "Receive user_sources_data: #{inspect user_sources_data}"

    Enum.each(user_sources_data, fn user_source_data -> user_id = elem(user_source_data, 0)
							source_ids = elem(user_source_data, 1)
		
							IO.inspect "Broadcast for user_id: #{user_id}, source_ids: #{inspect source_ids}"
							Phoenix.PubSub.broadcast(Collector.PubSub, "result_update_user:#{user_id}", {:source_ids_for_update, source_ids})
						     end)

    {:noreply, state}
  end
end