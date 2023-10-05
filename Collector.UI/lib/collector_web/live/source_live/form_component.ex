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

  def handle_event("save", %{"source" => source_params}, socket) do
    save_source(socket, socket.assigns.action, source_params)
  end

  defp save_source(socket, :new, source_params) do
    source = %{
      user_id: source_params["user_id"],
      type: source_params["type"],
      value: source_params["value"],
      options: "",
      interval: source_params["interval"]
    }

    case Recordings.create_source(source) do
      {:ok, created_source} ->

        task = Task.async(fn -> :erpc.call(:"worker@127.0.0.1", Collector.Workers, :enable_source, [created_source.id]) end)
        Task.await(task, 5000)
        |> IO.inspect

        {:noreply,
         socket
         |> put_flash(:info, "Source created successfully.")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect "error"
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
