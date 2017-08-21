defmodule TogglyApi.FeatureController do
  use TogglyApi, :controller
  alias Toggly.Features
  alias Toggly.Features.Request
  alias TogglyApi.FeatureParams
  require Logger

  action_fallback TogglyApi.FallbackController

  def is_active(conn, params) do
    feature_params = Map.delete(params, "feature_name")
    check_and_render(conn, params["feature_name"], feature_params)
  end

  defp check_and_render(conn, feature_name, params) do
    changeset = FeatureParams.changeset(%FeatureParams{}, params)
    case changeset do
          %{:params => validated_params, :valid? => true} ->
             request = to_struct(Request, Map.put(validated_params, "user", to_struct(Request.User, validated_params)))
             is_active = Features.Logic.is_enabled?(feature_name, request)
             render conn, "is_active.json", is_active: is_active
          _ ->
              conn
              |> put_status(400)
              |> text("Error, wrong parameters supplied!")
      end
  end

  def to_struct(kind, attrs) do
      struct = struct(kind)
      Enum.reduce Map.to_list(struct), struct, fn {k, _}, acc ->
        case Map.fetch(attrs, Atom.to_string(k)) do
          {:ok, v} -> %{acc | k => v}
          :error -> acc
        end
      end
    end

  def list(conn, _params) do
    features = Features.list_features()
    render conn, "list.json", features: features
  end
end
