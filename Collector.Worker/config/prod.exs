import Config

config :worker, Collector.Repo,
  url: "postgresql://pingrobotdb_owner:endpoint=ep-royal-smoke-a29ipfm6;56uhRPFJCvEq@ep-royal-smoke-a29ipfm6.eu-central-1.aws.neon.tech/pingrobotdb",
  maintenance_database: "pingrobotdb",
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