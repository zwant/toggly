defmodule TogglyApi.FeatureController do
  use TogglyApi, :controller
  alias Toggly.Features
  alias Toggly.Features.Request

  require Logger

  action_fallback TogglyApi.FallbackController

  def is_active(conn, params) do
    feature_params = Map.delete(params, "feature_name")
    check_and_render(conn, params["feature_name"], feature_params)
  end

  defp check_and_render(conn, feature_name, params) do

    true = validate_params(params)
    request = %Request{timestamp: Map.get(params, "timestamp"),
                       server_ip_address: Map.get(params, "server_ip_address"),
                       user: %Request.User{user_id: Map.get(params, "user_id"),
                                           username: Map.get(params, "username"),
                                           region: Map.get(params, "region")}}
    is_active = Features.Logic.is_enabled?(feature_name, request)
    render conn, "is_active.json", is_active: is_active
  end

  defp validate_params(params) do
    Enum.all?(params, fn {k, v} -> validate_single_param(k, v) end)
  end

  defp validate_single_param(param_name, value) do
    case param_name do
      "timestamp" ->
        {result, _} = Calendar.DateTime.Parse.rfc3339_utc(value)
        result == :ok
      _ -> :ok
    end
  end

  def list(conn, _params) do
    features = Features.list_features()
    render conn, "list.json", features: features
  end
end
