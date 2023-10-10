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
    IO.inspect "user_sources_update: #{inspect user_sources_update} received."

    process_pattern = "Elixir.CollectorWeb.SourceLive.Index"

    active_user_ids = Process.registered()
    |> Enum.map(fn process_name -> to_string(process_name) end)
    |> Enum.filter(fn process_name_string -> String.starts_with?(process_name_string, process_pattern) end)
    |> Enum.map(fn process_name_string -> String.split(process_name_string, "-") |> Enum.at(1) |> String.to_integer end)

    actual_user_source_update = user_sources_update
    |> Enum.filter(fn user_source -> Enum.member?(active_user_ids, elem(user_source, 0)) end)
    |> IO.inspect
    |> Enum.each(fn actual_user_source -> send_update(process_pattern, actual_user_source) end)
  end

  defp send_update(process_pattern, actual_user_source) do
    user_id = elem(actual_user_source, 0)
    source_ids = elem(actual_user_source, 1)
    pid = :"#{process_pattern}-#{user_id}"

    source_ids
    |> Enum.each(fn source_id -> send(pid, {:load_data, source_id}) 
                                 IO.inspect "Send update to: #{pid}, source_id: #{source_id}"
    end)
  end

end
