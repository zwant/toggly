use Mix.Config

# Configure your database
config :toggly, Toggly.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "toggly_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
