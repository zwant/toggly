# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :toggly_api,
  namespace: TogglyApi,
  ecto_repos: [Toggly.Repo]

# Configures the endpoint
config :toggly_api, TogglyApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RjcmCHiwBbi9mDoqRR7TKezigL+R/KEXL8zJeUHoAuZxvICd3uhmPgWlPDnhxpWb",
  render_errors: [view: TogglyApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: TogglyApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :toggly_api, :generators,
  context_app: :toggly

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
