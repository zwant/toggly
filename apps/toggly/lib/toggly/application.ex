defmodule Toggly.Application do
  @moduledoc """
  The Toggly Application Service.

  The toggly system business domain lives in this application.

  Exposes API to clients such as the `TogglyApi` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(Toggly.Repo, []),
      worker(Cachex, [:apicache, []])
    ], strategy: :one_for_one, name: Toggly.Supervisor)
  end
end
