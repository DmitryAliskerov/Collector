import Config

# Configure your database to ElephantSQL
#config :worker, Collector.Repo,
#  url: "postgres://qojtvwmd:kz-gzgywFRYa0M7vlumg6CXm3iHsZuSR@john.db.elephantsql.com/qojtvwmd",
#  maintenance_database: "qojtvwmd",
#  show_sensitive_data_on_connection_error: true,
#  pool_size: 2

# Configure your database to Local
#config :worker, Collector.Repo,
#  username: "postgres",
#  password: "postgres",
#  database: "postgres1",
#  hostname: "localhost",
#  show_sensitive_data_on_connection_error: true,
#  pool_size: 10

config :worker, Collector.Repo,
  url: "postgres://qojtvwmd:kz-gzgywFRYa0M7vlumg6CXm3iHsZuSR@john.db.elephantsql.com/qojtvwmd",
  maintenance_database: "qojtvwmd",
  tcp_keepalives_idle: 300,
  tcp_keepalives_interval: 60,
  tcp_keepalives_count: 5,
  queue_target: 5000,
#  username: "collector_zun2_user",
#  password: "pDQSfPGmYfUcYmZ0rPcnjspDF0IxESTW",
#  database: "collector_zun2",
#  hostname: "dpg-cqj18r6ehbks73c457pg-a.frankfurt-postgres.render.com",
#  ssl: true,
#  ssl_opts: [
#    verify: :verify_peer,
#    cacertfile: "priv/cert/selfsigned.pem",
#    versions: [:"tlsv1.3"]
#  ],
#  ssl: true, 
#  ssl_opts: [verify: :verify_peer, cacertfile: "priv/cert/selfsigned.pem"],
#  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  max_connections: 1

