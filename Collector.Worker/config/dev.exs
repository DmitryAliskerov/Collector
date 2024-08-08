import Config

#config :worker, Collector.Repo,
#  username: "postgres",
#  password: "postgres",
#  database: "postgres1",
#  hostname: "localhost",
#  url: "postgresql://collector_user:hFWYoqqxsVuCNdQmPJNUK6vRBr4c111s@dpg-cqjp7d0gph6c739bgv30-a.frankfurt-postgres.render.com/collector_eu72",
#  maintenance_database: "collector_eu72",
#  ssl: true,
#  ssl_opts: [keyfile: "priv/cert/key.pem", certfile: "priv/cert/cer.pem", verify: :verify_none],
#  port: 5432,
#  tcp_keepalives_idle: 300,
#  tcp_keepalives_interval: 60,
#  tcp_keepalives_count: 5,
#  queue_target: 5000,
#  pool_size: 10

config :worker, Collector.Repo,
  database: "../database.db",
  queue_target: 5000,
  pool_size: 10

