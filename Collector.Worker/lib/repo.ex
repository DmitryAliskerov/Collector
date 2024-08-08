defmodule Collector.Repo do
  use Ecto.Repo,
    otp_app: :worker,
    adapter: Ecto.Adapters.SQLite3
end
