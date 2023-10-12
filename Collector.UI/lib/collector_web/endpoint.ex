defmodule CollectorWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :collector

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_collector_key",
    signing_salt: "BAYSq+Lw"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :collector,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :collector
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug CollectorWeb.Router

  def update_user_sources(user_sources_update) do
    IO.inspect "Receive user_sources_update: #{inspect user_sources_update}"

    Enum.each(user_sources_update, fn user_source_update -> send_update(user_source_update) end)
  end

  defp send_update(user_source_update) do
    user_id = elem(user_source_update, 0)
    source_ids = elem(user_source_update, 1)

    IO.inspect "Broadcast for user_id: #{user_id}, source_ids: #{inspect source_ids}"
    Phoenix.PubSub.broadcast(Collector.PubSub, "user:#{user_id}", {:source_ids_for_update, source_ids})
  end

end
