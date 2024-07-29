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