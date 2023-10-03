defmodule Collector.Recordings.Data do
  use Ecto.Schema
  import Ecto.Changeset

  schema "data" do
    field :source_id, :integer
    field :timestamp, :utc_datetime
    field :value, :string
  end

  @doc false
  def changeset(data, attrs) do
    data
    |> cast(attrs, [:source_id, :timestamp, :value])
    |> validate_required([:source_id, :timestamp, :value])
  end
end