defmodule TogglyAdmin.FeatureController do
  use TogglyAdmin, :controller
  alias Toggly.Features

  def index(conn, _params) do
    features = Features.list_features
    render conn, "index.html", features: features
  end

  def toggle(conn, %{"feature_name" => feature_name}) do
    Features.Logic.toggle_feature(feature_name)
    redirect conn, to: "/"
  end
end
