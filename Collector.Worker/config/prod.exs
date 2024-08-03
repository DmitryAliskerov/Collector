import Config

config :worker, Collector.Repo,
  url: "postgresql://collector_user:9McQDIWPjZyx2kx2pCbS47ZtxxEY5Uv1@dpg-cqn147o8fa8c73ajpn1g-a.frankfurt-postgres.render.com/collector_ezjm",
  maintenance_database: "collector_ezjm",
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