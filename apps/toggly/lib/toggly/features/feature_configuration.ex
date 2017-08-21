defmodule Toggly.Features.FeatureConfiguration do
  use Ecto.Schema
  import Ecto.Changeset
  alias Toggly.Features.{Feature, FeatureConfiguration, Logic}


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "feature_configurations" do
    field :is_active, :boolean, default: false
    field :strategies, {:array, :string}, default: []
    field :parameters, :map, default: %{}
    belongs_to :feature, Feature

    timestamps()
  end

  @doc false
  def changeset(%FeatureConfiguration{} = feature_configuration, attrs) do
    feature_configuration
    |> cast(attrs, [:is_active, :strategies, :parameters])
    |> validate_required([:is_active])
    |> validate_strategy_parameters(:parameters)
  end

  def validate_strategy_parameters(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, new_parameters ->
      data_to_check = changeset.changes |> Map.get(:strategies, changeset.data.strategies)
      case Logic.validate_feature_config_params?(data_to_check, new_parameters) do
        true -> []
        false -> [{field, options[:message] || "Invalid Parameters"}]
      end
    end)
  end
end
