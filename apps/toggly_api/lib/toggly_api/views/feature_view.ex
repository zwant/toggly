defmodule TogglyApi.FeatureView do
  use TogglyApi, :view

  def render("list.json", %{features: features}) do
    %{features: Enum.map(features, &feature_json/1)}
  end

  def render("is_active.json", %{is_active: is_active}) do
    %{is_active: is_active}
  end

  defp feature_json(feature) do
    %{id: feature.id,
      label: feature.label,
      created_at: feature.inserted_at,
      configuration: feature_config_json(feature.configuration)}
  end

  defp feature_config_json(feature_config) do
    %{is_active: feature_config.is_active}
  end


end
