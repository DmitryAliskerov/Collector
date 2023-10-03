defmodule CollectorWeb.SourceLive.Index do
  use CollectorWeb, :live_view

  alias Collector.Recordings
  alias Collector.Recordings.Source

  @impl true
  def mount(_params, _session, socket) do
    
    if connected?(socket), do: Recordings.subscribe()

    sources = list_sources(socket.assigns.current_user.id)

    for source <- sources do
      send(self(), {:load_data, source.id, get_data_id(source.id)})
    end
    
    {:ok, assign(socket, :sources, sources), temporary_assigns: [sources: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Source")
    |> assign(:source, Recordings.get_source!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Source")
    |> assign(:source, %Source{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Source")
    |> assign(:source, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    source = Recordings.get_source!(id)
    {:ok, _} = Recordings.delete_source(source)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:source_created, source}, socket) do
    {:noreply, update(socket, :sources, fn sources -> [source | sources] end)}
  end
  
  def handle_info({:source_updated, source}, socket) do
    {:noreply, update(socket, :sources, fn sources -> [source | sources] end)}
  end

  def handle_info({:load_data, source_id, source_data_id}, socket) do
    Process.send_after(self(), {:load_data, source_id, source_data_id}, 10 * 1000)

    IO.inspect "Updated: #{source_id}"
    
    results = list_data(source_id)
    send_update CollectorWeb.SourceLive.DataComponent, id: source_data_id, loading: false, results: results
    
    {:noreply, socket}
  end  

  #def handle_info({:"source_deleted"}, socket) do
  #  {:noreply, update(socket, :sources, fn sources -> sources end)}
  #end

  def get_data_id(source_id) do
    "source-#{source_id}-data"
  end

  defp list_sources(user_id) do
    Recordings.list_sources(user_id)
  end

  defp list_data(source_id) do
    Recordings.list_data(source_id)
  end

  on_mount {CollectorWeb.LiveAuth, :require_authenticated_user}
end
