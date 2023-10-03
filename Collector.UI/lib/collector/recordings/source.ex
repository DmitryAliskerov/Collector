defmodule Collector.Recordings.Source do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sources" do
    field :user_id, :integer
    field :type, :string
    field :value, :string
    field :options, :string
    field :interval, :integer
  end

  @doc false
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:user_id, :type, :value, :options, :interval])
    |> validate_required([:user_id, :type, :value, :interval])
  end
end