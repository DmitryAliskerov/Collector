defmodule CollectorWeb.SourceLive.Show do
  use CollectorWeb, :live_view

  alias Collector.Recordings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:source, Recordings.get_source!(id))}
  end

  defp page_title(:show), do: "Show Source"
  defp page_title(:edit), do: "Edit Source"
end
