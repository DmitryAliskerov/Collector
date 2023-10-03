defmodule Collector.Worker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Cluster.Supervisor, [topologies(), [name: SimpleCluster.ClusterSupervisor]]},
      Collector.Repo,
      {Oban, Application.fetch_env!(:worker, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Collector.Workers.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: [
            :"ui@127.0.0.1",
            :"worker@127.0.0.1"
          ]
        ]
      ]
    ]
  end

end
