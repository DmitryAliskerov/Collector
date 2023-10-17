defmodule CollectorWeb.SourceLive.FormComponent do
  use CollectorWeb, :live_component

  alias Collector.Recordings

  @impl true
  def update(%{source: source} = assigns, socket) do
    changeset = Recordings.change_source(source)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"source" => source_params}, socket) do
    changeset =
      socket.assigns.source
      |> Recordings.change_source(source_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"source" => source_params}, socket) do
    IO.inspect "Create source."

    source = %{
      user_id: source_params["user_id"],
      type: source_params["type"],
      value: source_params["value"],
      options: "",
      interval: source_params["interval"]
    }

    case Recordings.create_source(source) do
      {:ok, created_source} ->
         Phoenix.PubSub.direct_broadcast(:"worker@127.0.0.1", Collector.PubSub, "source_changer", {:create_source, created_source})
         {:noreply, socket |> push_redirect(to: socket.assigns.return_to)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
