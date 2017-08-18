defmodule TogglyApi.FeatureParams do
  use Ecto.Schema

  import Ecto.Changeset

  schema "FeatureParams" do
    field :timestamp, :string
    field :server_ip_address, :string
    field :user_id, :string
    field :username, :string
    field :region, :string
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:timestamp, :server_ip_address, :user_id, :username, :region])
    |> validate_required([])
    |> validate_timestamp_format(:timestamp)
  end

  def validate_timestamp_format(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, value ->
      case Calendar.DateTime.Parse.rfc3339_utc(value) do
        {:ok, _} -> []
        _ -> [{field, options[:message] || "Not a valid rfc3339_utc timestamp"}]
      end
    end)
  end
end
