defmodule CollectorWeb.SourceLive.FormComponent do
  use CollectorWeb, :live_component

  alias Collector.Recordings
  alias Collector.Recordings.Source

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

  def handle_event("save", %{"source" => source_params}, socket) do
    save_source(socket, socket.assigns.action, source_params)
  end

#  defp save_source(socket, :edit, source_params) do
#    case Recordings.update_source(socket.assigns.source, source_params) do
#      {:ok, _source} ->
#        {:noreply,
#         socket
#         |> put_flash(:info, "source updated successfully")
#         |> push_redirect(to: socket.assigns.return_to)}
#
#      {:error, %Ecto.Changeset{} = changeset} ->
#        {:noreply, assign(socket, :changeset, changeset)}
#    end
#  end

  defp save_source(socket, :new, source_params) do

    IO.inspect socket

    user_id = 1

    source = %{
      user_id: user_id,
      type: "URL",
      value: source_params["value"],
      options: "",
      interval: 10
    }

    IO.inspect source_params
    IO.inspect source

    case Recordings.create_source(source) do
      {:ok, _source} ->
        {:noreply,
         socket
         |> put_flash(:info, "Album created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect "error"
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
