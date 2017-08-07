use Mix.Config

config :toggly, ecto_repos: [Toggly.Repo]

import_config "#{Mix.env}.exs"
