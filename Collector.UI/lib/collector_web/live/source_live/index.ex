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

    Phoenix.PubSub.subscribe(Collector.PubSub, "result_update_user:#{socket.assigns.current_user.id}")
    Phoenix.PubSub.subscribe(Collector.PubSub, "change_source_answer")

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
  def handle_info({:create_source_ok, source}, socket) do
    IO.inspect "Source was created. Source_id: #{source.id}"

    {:noreply, socket}
  end

  def handle_info({:switch_source_error, source}, socket) do
    IO.inspect "Source was not created."

    {:noreply, socket}
  end

  @impl true
  def handle_info({:switch_source_ok, source, new_enabled_state}, socket) do
    case Recordings.update_source(source, %{enabled: new_enabled_state}) do
      {:ok, _} ->
        IO.inspect "Source was updated. Source_id: #{source.id}, new_enabled_state: #{new_enabled_state}"
        send_update CollectorWeb.SourceLive.SwitchComponent, id: get_switch_id(source.id), enabled: new_enabled_state, waiting: false
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("switch-source", %{"id" => source_id}, socket) do
    IO.inspect "Enable/Disable source. Source_id: #{source_id}"

    send_update CollectorWeb.SourceLive.SwitchComponent, id: CollectorWeb.SourceLive.Index.get_switch_id(source_id), waiting: true

    source = Recordings.get_source!(source_id)
    new_enabled_state = !source.enabled

    Phoenix.PubSub.direct_broadcast(:"worker@127.0.0.1", Collector.PubSub, "source_changer", {:switch_source, source, new_enabled_state})

    {:noreply, socket}
  end

  def handle_info({:switch_source_error, source, new_enabled_state}, socket) do
    IO.inspect "Source was not updated. Source_id: #{source.id}, new_enabled_state: #{new_enabled_state}"
    send_update CollectorWeb.SourceLive.SwitchComponent, id: get_switch_id(source.id), waiting: false

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete-source", %{"id" => source_id}, socket) do
    IO.inspect "Delete source. Source_id: #{source_id}"

    source = Recordings.get_source!(source_id)

    if source.enabled do
      Phoenix.PubSub.direct_broadcast(:"worker@127.0.0.1", Collector.PubSub, "source_changer", {:delete_source, source})
    else
      send(self(), {:delete_source_ok, source})
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:delete_source_ok, source}, socket) do
    case Recordings.delete_source(source) do
      {:ok, _} ->
        IO.inspect "Source was deleted. Source_id: #{source.id}"
        {:noreply, assign(socket, :sources, Recordings.list_sources(socket.assigns.current_user.id))}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_info({:delete_source_error, source}, socket) do
    {:noreply, socket}
  end

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