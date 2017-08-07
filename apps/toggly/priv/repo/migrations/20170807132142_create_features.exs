defmodule Toggly.Repo.Migrations.CreateFeatures do
  use Ecto.Migration

  def change do
    create table(:features, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string

      timestamps()
    end

    create unique_index(:features, [:label])
  end
end
