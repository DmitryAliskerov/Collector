defmodule Collector.Repo.Migrations.CreateData do
  use Ecto.Migration

  def change do
    create table(:data) do
      add :source_id, :bigint
      add :timestamp, :utc_datetime
      add :value, :string   
    end
  end
end