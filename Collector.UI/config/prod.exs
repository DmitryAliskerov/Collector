import Config

# Configure your database
config :collector, Collector.Repo,
  url: "postgresql://collector_user:hFWYoqqxsVuCNdQmPJNUK6vRBr4c111s@dpg-cqjp7d0gph6c739bgv30-a.frankfurt-postgres.render.com/collector_eu72",
  maintenance_database: "collector_eu72",
  ssl: true,
  ssl_opts: [
    keyfile: "priv/cert/key.pem",
    certfile: "priv/cert/cer.pem",
    verify: :verify_none
  ],
  port: 5432,
  tcp_keepalives_idle: 300,
  tcp_keepalives_interval: 60,
  tcp_keepalives_count: 5,
  queue_target: 5000,
  pool_size: 10


# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :collector, CollectorWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {0, 0, 0, 0}, port: 80],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "Tv0997u8XBodoCmMnJUZIHi6WPupPpRFHdbJGcdAK6FLPAC6rMbVc8Yt0mBDncHy1",
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}
  ]

# Watch static and templates for browser reloading.
config :collector, Collector.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/collector_web/(live|views)/.*(ex)$",
      ~r"lib/collector_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix, :json_library, Jason