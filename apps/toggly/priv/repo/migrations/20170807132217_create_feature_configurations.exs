defmodule Toggly.Repo.Migrations.CreateFeatureConfigurations do
  use Ecto.Migration

  def change do
    create table(:feature_configurations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_active, :boolean, default: false, null: false
      add :feature_id, references(:features, on_delete: :delete_all, type: :binary_id)
      add :strategies, {:array, :string}
      add :parameters, :map

      timestamps()
    end

    create index(:feature_configurations, [:feature_id])
  end
end
