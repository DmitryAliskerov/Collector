import Config

config :worker, ecto_repos: [Collector.Repo]

config :worker, Oban,
  repo: Collector.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

import_config "#{config_env()}.exs"