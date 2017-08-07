defmodule Toggly.Features.Feature do
  use Ecto.Schema
  import Ecto.Changeset
  alias Toggly.Features.{Feature, FeatureConfiguration}


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "features" do
    field :label, :string
    has_one :configuration, FeatureConfiguration

    timestamps()
  end

  @doc false
  def changeset(%Feature{} = feature, attrs) do
    feature
    |> cast(attrs, [:label])
    |> validate_required([:label])
    |> unique_constraint(:label)
  end
end
