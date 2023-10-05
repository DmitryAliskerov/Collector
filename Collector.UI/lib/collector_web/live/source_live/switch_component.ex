defmodule CollectorWeb.SourceLive.SwitchComponent do
  use CollectorWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <label 
        id={@id}
        class="switch"
        phx-click="toggle-switch"
        phx-value-id={@source_id}
      >
        <span 
          class={"#{if @enabled, do: "checked", else: ""}"}
        ></span>
        <span 
          class="slider round"
        >
          <span 
            class={"#{if @waiting, do: "loader", else: ""}"}
          ></span>
        </span>
      </label>
    """
  end

end
