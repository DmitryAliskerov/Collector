defmodule CollectorWeb.SourceLive.SourceComponent do
  use CollectorWeb, :live_component

  def render(assigns) do
    ~H"""
      <div id={"source-#{@source.id}"} class="source" style="border-style: solid; border-color: #aaa; border-width: 2px; padding: 16px; margin-bottom: 8px;">
        <div class="row">
          <div class="column column-90 source-body">
            <b>Type: <%= @source.type %></b>
          </div>
          <div class="column column-90 source-body">
            <b>Target: <%= @source.value %></b>
          </div>

          <%= live_component CollectorWeb.SourceLive.DataComponent, id: CollectorWeb.SourceLive.Index.get_data_id(@source.id), source_id: @source.id, loading: true %>
          
          <%= link to: "#", phx_click: "delete", phx_value_id: @source.id do %>
            Delete
          <% end %>
        </div>
      </div>
    """
  end
end
