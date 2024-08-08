import Config

config :worker, Collector.Repo,
#  username: "postgres",
#  password: "postgres",
#  database: "postgres1",
#  hostname: "localhost",
  url: "tgresql://pingrobotdb_owner:xQlwDRHr70cn@ep-holy-waterfall-a2xsb27f.eu-central-1.aws.neon.tech/pingrobotdb?sslmode=require",
  maintenance_database: "pingrobotdb",
  ssl: true,
  ssl_opts: [keyfile: "priv/cert/key.pem", certfile: "priv/cert/cer.pem", verify: :verify_none],
  port: 5432,
  tcp_keepalives_idle: 300,
  tcp_keepalives_interval: 60,
  tcp_keepalives_count: 5,
  queue_target: 5000,
  pool_size: 10