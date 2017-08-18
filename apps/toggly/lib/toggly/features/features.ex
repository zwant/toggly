defmodule Toggly.Features do
  @moduledoc """
  The Features context.
  """

  import Ecto.Query, warn: false
  alias Toggly.Repo
  require Logger
  use Toggly.Features.Strategies
  alias Toggly.Features.Strategies

  alias Toggly.Features.{Feature, FeatureConfiguration, Request}

  defmodule Logic do
    alias Toggly.Features

    def is_enabled?(feature_label) do
      feature = Features.get_feature_from_cache(feature_label)
      feature_active?(feature.configuration)
    end

    def is_enabled?(feature_label, request = %Request{}) do
      feature = Features.get_feature_from_cache(feature_label)
      request_feature_enabled?(feature.configuration, request)
    end

    def validate_feature_config_params?(strategy_names, incoming_params) do
      get_strategies_with_names(strategy_names) |>
        Strategies.ActivationStrategy.validate_params?(incoming_params)
    end

    defp request_feature_enabled?(configuration, request = %Request{}) do
      strategies = get_strategies_for_configuration(configuration)
      log_active_strats(configuration, strategies)

      feature_active?(configuration)
        && Enum.all?(strategies, fn str -> Strategies.ActivationStrategy.evaluate(str, request, configuration.parameters) end)
    end

    defp log_active_strats(config, strategies) do
      strat_str = Enum.join(Enum.map(strategies, fn str -> str.name() end), ", ")
      Logger.info("Active rules for config #{config.id}: #{strat_str}")
    end

    defp feature_active?(configuration), do: configuration.is_active

    defp get_strategies_for_configuration(configuration) do
      get_strategies_with_names(configuration.strategies)
    end

    defp get_strategies_with_names(name_list) do
      Enum.filter(Strategies.get_all(), fn str -> str.name() in name_list end)
    end
  end
  @doc """
  Returns the list of features.

  ## Examples

      iex> list_features()
      [%Feature{}, ...]

  """
  def list_features do
    Repo.all from feature in Feature,
      left_join: configuration in assoc(feature, :configuration),
      preload: [configuration: configuration]
  end

  @doc """
  Gets a single feature.

  Raises `Ecto.NoResultsError` if the Feature does not exist.

  ## Examples

      iex> get_feature!(123)
      %Feature{}

      iex> get_feature!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feature!(id) do
    Repo.one from feature in Feature,
      where: feature.id == ^id,
      left_join: configuration in assoc(feature, :configuration),
      preload: [configuration: configuration]
  end

  def get_feature_by_label!(label) do
    Repo.one from feature in Feature,
      where: feature.label == ^label,
      left_join: configuration in assoc(feature, :configuration),
      preload: [configuration: configuration]
  end

  def get_feature_from_cache(label) do
    # Look it up in the cache
    case Cachex.get(:apicache, label) do
      # No hit
      {:missing, _} ->
        feature = get_feature_by_label!(label)
        Cachex.set(:apicache, label, feature, [ ttl: :timer.seconds(1800)])
        feature

      {:ok, result} -> result
    end
  end

  def update_feature_in_cache(feature) do
    Cachex.set(:apicache, feature.label, feature, [ ttl: :timer.seconds(1800)])
  end

  def evict_feature_from_cache(feature) do
    Cachex.del(:apicache, feature.label)
  end

  @doc """
  Creates a feature.

  ## Examples

      iex> create_feature(%{field: value})
      {:ok, %Feature{}}

      iex> create_feature(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feature(attrs \\ %{}) do
    %Feature{}
    |> Feature.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:configuration, with: &FeatureConfiguration.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Updates a feature.

  ## Examples

      iex> update_feature(feature, %{field: new_value})
      {:ok, %Feature{}}

      iex> update_feature(feature, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feature(%Feature{} = feature, attrs) do
    result = feature
    |> Feature.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:configuration, with: &FeatureConfiguration.changeset/2)
    |> Repo.update()

    case result do
      {:ok, feature} ->
        update_feature_in_cache(feature)
        {:ok, feature}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a Feature.

  ## Examples

      iex> delete_feature(feature)
      {:ok, %Feature{}}

      iex> delete_feature(feature)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feature(%Feature{} = feature) do
    case Repo.delete(feature) do
      {:ok, _} -> evict_feature_from_cache(feature)
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feature changes.

  ## Examples

      iex> change_feature(feature)
      %Ecto.Changeset{source: %Feature{}}

  """
  def change_feature(%Feature{} = feature) do
    Feature.changeset(feature, %{})
  end



  @doc """
  Returns the list of feature_configurations.

  ## Examples

      iex> list_feature_configurations()
      [%FeatureConfiguration{}, ...]

  """
  def list_feature_configurations do
    Repo.all(FeatureConfiguration)
  end

  @doc """
  Gets a single feature_configuration.

  Raises `Ecto.NoResultsError` if the Feature configuration does not exist.

  ## Examples

      iex> get_feature_configuration!(123)
      %FeatureConfiguration{}

      iex> get_feature_configuration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feature_configuration!(id), do: Repo.get!(FeatureConfiguration, id)

  @doc """
  Creates a feature_configuration.

  ## Examples

      iex> create_feature_configuration(%{field: value})
      {:ok, %FeatureConfiguration{}}

      iex> create_feature_configuration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feature_configuration(attrs \\ %{}) do
    %FeatureConfiguration{}
    |> FeatureConfiguration.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a feature_configuration.

  ## Examples

      iex> update_feature_configuration(feature_configuration, %{field: new_value})
      {:ok, %FeatureConfiguration{}}

      iex> update_feature_configuration(feature_configuration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feature_configuration(%FeatureConfiguration{} = feature_configuration, attrs) do
    feature_configuration
    |> FeatureConfiguration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a FeatureConfiguration.

  ## Examples

      iex> delete_feature_configuration(feature_configuration)
      {:ok, %FeatureConfiguration{}}

      iex> delete_feature_configuration(feature_configuration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feature_configuration(%FeatureConfiguration{} = feature_configuration) do
    Repo.delete(feature_configuration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feature_configuration changes.

  ## Examples

      iex> change_feature_configuration(feature_configuration)
      %Ecto.Changeset{source: %FeatureConfiguration{}}

  """
  def change_feature_configuration(%FeatureConfiguration{} = feature_configuration) do
    FeatureConfiguration.changeset(feature_configuration, %{})
  end
end
