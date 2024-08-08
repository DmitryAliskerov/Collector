defmodule Collector.Repo do
  use Ecto.Repo,
    otp_app: :collector,
    adapter: Ecto.Adapters.SQLite3
end
