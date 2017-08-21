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

    @doc """
    Checks if the feature with the given `feature_label` is currently enabled.
    Does not receive a request, so can only return on the global state of the feature toggle.

    ## Parameters

      - feature_label: `String` with the label for the feature.

    ## Returns

    `boolean`

    """
    def is_enabled?(feature_label) do
      case Features.get_feature_from_cache(feature_label) do
        {:error, _} ->
          create_disabled_feature(feature_label)
          false
        {:ok, feature} ->
          feature_active?(feature.configuration)
      end
    end

    @doc """
    Checks if the feature with the given `feature_label` is enabled for the given
    `request`. It's up to each feature's configuration to determine how to inspect
    the request contents.

    ## Parameters

      - feature_label: `String` with the label for the feature.
      - request: `t:Toggly.Features.Request/0` with the label for the feature.

    ## Returns

    boolean

    """
    def is_enabled?(feature_label, request = %Request{}) do
      case Features.get_feature_from_cache(feature_label) do
        {:error, _} ->
          create_disabled_feature(feature_label)
          false
        {:ok, feature} ->
          request_feature_enabled?(feature.configuration, request)
      end
    end

    def validate_feature_config_params?(strategy_names, incoming_params) do
      get_strategies_with_names(strategy_names) |>
        Strategies.ActivationStrategy.validate_params?(incoming_params)
    end

    def toggle_feature(feature_label) do
      feature = Features.get_feature_by_label(feature_label)
      Features.update_feature_configuration(feature.configuration, %{"is_active": !feature.configuration.is_active})
    end

    defp create_disabled_feature(feature_label) do
      Features.create_feature(%{"label": feature_label,
                                "configuration": %{"is_active": false}})
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
  def get_feature(id) do
    Repo.one from feature in Feature,
      where: feature.id == ^id,
      left_join: configuration in assoc(feature, :configuration),
      preload: [configuration: configuration]
  end

  def get_feature_by_label(label) do
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
        case get_feature_by_label(label) do
          nil -> {:error, "No result found"}
          feature -> Cachex.set(:apicache, label, feature, [ ttl: :timer.seconds(1800)])
                     {:ok, feature}
        end

      {:ok, result} -> {:ok, result}
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
