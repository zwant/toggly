defmodule TogglyApi.Router do
  use TogglyApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TogglyApi do
    pipe_through :api

    get "/feature/:feature_name/is_active", FeatureController, :is_active
    get "/feature", FeatureController, :list
  end
end
