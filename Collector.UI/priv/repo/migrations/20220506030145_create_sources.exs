defmodule Collector.Repo.Migrations.CreateSources do
  use Ecto.Migration

  def change do
    create table(:sources) do
      add :user_id, :integer
      add :type, :string
      add :value, :string
      add :options, :string
      add :interval, :integer
      add :enabled, :boolean
    end
  end
end
