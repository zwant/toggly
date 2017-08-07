defmodule Toggly.Features.FeatureConfiguration do
  use Ecto.Schema
  import Ecto.Changeset
  alias Toggly.Features.{Feature, FeatureConfiguration}


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "feature_configurations" do
    field :is_active, :boolean, default: false
    belongs_to :feature, Feature

    timestamps()
  end

  @doc false
  def changeset(%FeatureConfiguration{} = feature_configuration, attrs) do
    feature_configuration
    |> cast(attrs, [:is_active])
    |> validate_required([:is_active])
  end
end
