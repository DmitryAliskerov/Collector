import Config

# Configure your database to ElephantSQL
#config :worker, Collector.Repo,
#  url: "postgres://qojtvwmd:kz-gzgywFRYa0M7vlumg6CXm3iHsZuSR@john.db.elephantsql.com/qojtvwmd",
#  maintenance_database: "qojtvwmd",
#  show_sensitive_data_on_connection_error: true,
#  pool_size: 2

# Configure your database to Local
config :worker, Collector.Repo,
  username: "postgres",
  password: "postgres",
  database: "postgres1",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
