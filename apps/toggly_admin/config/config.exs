# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :toggly_admin,
  namespace: TogglyAdmin,
  ecto_repos: [TogglyAdmin.Repo]

# Configures the endpoint
config :toggly_admin, TogglyAdmin.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/GmKh75tjY0ALomqGmEpY9mkzPMF1m0voPpTpUgOlGdYlpA58sxq+yTJg0BiP2eM",
  render_errors: [view: TogglyAdmin.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TogglyAdmin.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :toggly_admin, :generators,
  context_app: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
