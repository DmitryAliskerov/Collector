defmodule CollectorWeb.SourceLive.DataComponent do
  use CollectorWeb, :live_component

  alias Contex.Plot
  alias Contex.LinePlot

  def update(assigns, socket) do
    if assigns[:loading] do
      {:ok,
       socket
       |> assign(assigns)}
    else
      {:ok,
       socket
       |> assign(assigns)
       |> assign_source_data(assigns.results)
       |> assign_dataset()
       |> assign_chart()
       |> assign_chart_svg()}
    end
  end

  defp assign_source_data(socket, results) do
    socket
    |> assign(:source_data, results)
  end

  defp datetime_formatter(d) do
    NaiveDateTime.to_string(d)
  end

  defp assign_chart(%{assigns: %{dataset: dataset}} = socket) do
    socket
    |> assign(
      :chart,
      LinePlot.new(
	dataset,
	custom_x_formatter: &datetime_formatter/1,
        smoothed: false))
  end

  defp assign_dataset(%{assigns: %{source_data: source_data}} = socket) do
    socket
    |> assign(:dataset, Contex.Dataset.new(source_data))
  end

  defp assign_chart_svg(%{assigns: %{chart: chart}} = socket) do
    socket
    |> assign(
      :chart_svg,
      Plot.new(800, 150, chart)
      |> Plot.axis_labels("", "ms")
      |> Plot.titles("", "Response time")
      |> Plot.to_svg())
  end
 
  def render(assigns) do
    ~H"""
      <div id={"#{@id}"}>
        <%= if @loading do %>
          Loading data...
        <% else %>
          <div class="chart">
            <%= @chart_svg %>
          </div>
        <% end %>
      </div>
    """
  end  
end