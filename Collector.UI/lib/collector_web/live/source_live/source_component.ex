defmodule CollectorWeb.SourceLive.SourceComponent do
  use CollectorWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <div id={"source-#{@source.id}"} class="source" style="border-style: solid; border-color: #aaa; border-width: 2px; padding: 16px; margin-bottom: 8px;">
        <div class="row">

          <%= link "", to: "#", phx_click: "delete-source", phx_value_id: @source.id, data: [confirm: "Are you sure?"], class: "gg-trash right m-l-25 #{if @trash_anim, do: 'anim', else: ''}" %>
          <%= live_component CollectorWeb.SourceLive.SwitchComponent, id: CollectorWeb.SourceLive.Index.get_switch_id(@source.id), source_id: @source.id, enabled: @source.enabled, waiting: false %>
                                                         
          <div class="column column-90 source-body">
            <b>Type: <%= @source.type %></b>
          </div>
          <div class="column column-90 source-body">
            <b>Target: <%= @source.value %></b>
          </div>
          <div class="column column-90 source-body">
            <b>Interval: <%= @source.interval %> seconds</b>
          </div>

          <%= live_component CollectorWeb.SourceLive.DataComponent,   id: CollectorWeb.SourceLive.Index.get_data_id(@source.id), source_id: @source.id, loading: true %>

        </div>
      </div>
    """
  end
end
