defmodule CollectorWeb.PageController do
  use CollectorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
