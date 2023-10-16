defmodule CollectorWeb.SourceLive.Index do
  use CollectorWeb, :live_view

  alias Collector.Recordings
  alias Collector.Recordings.Source

  @impl true
  def mount(_params, _session, socket) do
    sources = list_sources(socket.assigns.current_user.id)

    for source <- sources do
      send(self(), {:load_data, source.id})
    end

    Phoenix.PubSub.subscribe(Collector.PubSub, "user:#{socket.assigns.current_user.id}")

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
    |> assign(:page_title, "New URL Source")
    |> assign(:source, %Source{user_id: socket.assigns.current_user.id, type: "URL"})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Source")
    |> assign(:source, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    source = Recordings.get_source!(id)

    if source.enabled do
      :erpc.call(:"worker@127.0.0.1", Collector.UpdateReceiver, :call_disable_source, [source.id])
      |> IO.inspect
    end

    {:ok, _} = Recordings.delete_source(source)

    {:noreply, assign(
      socket
       |> put_flash(:info, "Source deleted successfully."),
      :sources,
      Recordings.list_sources(socket.assigns.current_user.id))}
  end

  def handle_event("toggle-switch", %{"id" => id}, socket) do

    send_update CollectorWeb.SourceLive.SwitchComponent, id: get_switch_id(id), waiting: true

    send(self(), {:toggle_switch_info, id})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:toggle_switch_info, id}, socket) do
    IO.inspect "Enable/Disable source."

    source = Recordings.get_source!(id)
    new_enabled = !source.enabled

    :erpc.call(:"worker@127.0.0.1", Collector.UpdateReceiver, ternary(new_enabled, :call_enable_source, :call_disable_source), [id])

    case Recordings.update_source(source, %{enabled: new_enabled}) do
      {:ok, _} ->
        send_update CollectorWeb.SourceLive.SwitchComponent, id: get_switch_id(id), enabled: new_enabled, waiting: false
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:source_ids_for_update, source_ids}, socket) do
    Enum.each(source_ids, fn source_id -> send(self(), {:load_data, source_id}) end)
    
    {:noreply, socket}
  end  

  def handle_info({:load_data, source_id}, socket) do
    results = list_data(source_id)
    send_update CollectorWeb.SourceLive.DataComponent, id: "source-#{source_id}-data", loading: false, results: results
    IO.inspect "Source: #{source_id} updated."
    
    {:noreply, socket}
  end  

  def get_data_id(source_id) do
    "source-#{source_id}-data"
  end

  def get_switch_id(source_id) do
    "source-#{source_id}-switch"
  end

  defp list_sources(user_id) do
    Recordings.list_sources(user_id)
  end

  defp list_data(source_id) do
    Recordings.list_data(source_id)
  end

  defp ternary(condition, true_val, false_val) do
    if(condition, do: true_val, else: false_val)
  end

  on_mount {CollectorWeb.LiveAuth, :require_authenticated_user}
end
