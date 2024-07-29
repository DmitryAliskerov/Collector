import Config

config :worker, Collector.Repo,
#  url: "postgres://qojtvwmd:kz-gzgywFRYa0M7vlumg6CXm3iHsZuSR@john.db.elephantsql.com/qojtvwmd",
#  maintenance_database: "qojtvwmd",
  url: "postgresql://collector:gqhbkDLKlBP2RRzigxqk6kOyTS14oSOl@dpg-cqj1ob0gph6c738vrsjg-a.singapore-postgres.render.com/collector_7q0n",
  maintenance_database: "collector_7q0n",
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
  pool_size: 10,
  max_connections: 1

config :worker, WorkerWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 80],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "C9JUJdHidxat8DdYq6SPRHt9WYdyKVhAYXVntKoPg9KhayMHkvXnjQICG22gNvmC",
  watchers: []

config :worker, WorkerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/worker_web/(live|views)/.*(ex)$",
      ~r"lib/worker_web/templates/.*(eex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix, :json_library, Jason

config :worker, WorkerWeb.Endpoint,
  pubsub_server: Collector.PubSub