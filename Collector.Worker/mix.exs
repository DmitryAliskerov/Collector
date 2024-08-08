defmodule Worker.MixProject do
  use Mix.Project

  def project do
    [
      app: :worker,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Collector.Worker.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.3"},
      {:phoenix, "~> 1.6.7"},
      #{:ecto_sql, "~> 3.6"},
      {:ecto_sqlite3, "~> 0.16"},
      {:postgrex, ">= 0.0.0"},
      {:oban, "~> 2.16.2"},
      {:toolshed, path: "fork_deps/toolshed"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.create", "ecto.migrate"],
    ]
  end  
end
