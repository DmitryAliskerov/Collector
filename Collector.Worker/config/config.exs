import Config

config :worker, ecto_repos: [Collector.Repo]

config :worker, Oban,
  repo: Collector.Repo,
  engine: Oban.Engines.Lite,
  queues: [default: 10]

import_config "#{config_env()}.exs"