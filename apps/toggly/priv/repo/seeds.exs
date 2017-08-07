# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Toggly.Repo.insert!(%Toggly.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Toggly.Repo
alias Toggly.Features.Feature
alias Toggly.Features.FeatureConfiguration

Repo.delete_all Feature
Repo.delete_all FeatureConfiguration

%Feature{label: "test"}
|> Ecto.Changeset.change
|> Ecto.Changeset.put_assoc(:configuration, FeatureConfiguration.changeset(%FeatureConfiguration{}, %{is_active: true}))
|> Repo.insert!

%Feature{label: "test2"}
|> Ecto.Changeset.change
|> Ecto.Changeset.put_assoc(:configuration, FeatureConfiguration.changeset(%FeatureConfiguration{}, %{is_active: false}))
|> Repo.insert!
