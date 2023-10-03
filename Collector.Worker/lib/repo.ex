defmodule Collector.Repo do
  use Ecto.Repo,
    otp_app: :worker,
    adapter: Ecto.Adapters.Postgres
end
