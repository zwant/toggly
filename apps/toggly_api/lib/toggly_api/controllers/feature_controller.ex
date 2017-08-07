defmodule TogglyApi.FeatureController do
  use TogglyApi, :controller
  alias Toggly.Features

  action_fallback TogglyApi.FallbackController

  def is_active(conn, %{"feature_name" => feature_name}) do
    feature = Features.get_feature_from_cache(feature_name)
    render conn, "is_active.json", is_active: feature.configuration.is_active
  end

  def list(conn, _params) do
    features = Features.list_features()
    render conn, "list.json", features: features
  end
end
