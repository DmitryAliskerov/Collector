defmodule Collector.Repo.Migrations.CreateSources do
  use Ecto.Migration

  def change do
    alter table(:sources) do
      add :enabled, :boolean, null: false, default: true
    end
  end
end
