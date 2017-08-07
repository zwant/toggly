defmodule Toggly.FeaturesTest do
  use Toggly.DataCase

  alias Toggly.Features

  describe "features" do
    alias Toggly.Features.Feature

    @valid_attrs %{label: "some label"}
    @update_attrs %{label: "some updated label"}
    @invalid_attrs %{label: nil}

    def feature_fixture(attrs \\ %{}) do
      {:ok, feature} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Features.create_feature()

      feature
    end

    test "list_features/0 returns all features" do
      feature = feature_fixture()
      assert Features.list_features() == [feature]
    end

    test "get_feature!/1 returns the feature with given id" do
      feature = feature_fixture()
      assert Features.get_feature!(feature.id) == feature
    end

    test "create_feature/1 with valid data creates a feature" do
      assert {:ok, %Feature{} = feature} = Features.create_feature(@valid_attrs)
      assert feature.label == "some label"
    end

    test "create_feature/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Features.create_feature(@invalid_attrs)
    end

    test "update_feature/2 with valid data updates the feature" do
      feature = feature_fixture()
      assert {:ok, feature} = Features.update_feature(feature, @update_attrs)
      assert %Feature{} = feature
      assert feature.label == "some updated label"
    end

    test "update_feature/2 with invalid data returns error changeset" do
      feature = feature_fixture()
      assert {:error, %Ecto.Changeset{}} = Features.update_feature(feature, @invalid_attrs)
      assert feature == Features.get_feature!(feature.id)
    end

    test "delete_feature/1 deletes the feature" do
      feature = feature_fixture()
      assert {:ok, %Feature{}} = Features.delete_feature(feature)
      assert_raise Ecto.NoResultsError, fn -> Features.get_feature!(feature.id) end
    end

    test "change_feature/1 returns a feature changeset" do
      feature = feature_fixture()
      assert %Ecto.Changeset{} = Features.change_feature(feature)
    end
  end

  describe "feature_configurations" do
    alias Toggly.Features.FeatureConfiguration

    @valid_attrs %{active: true}
    @update_attrs %{active: false}
    @invalid_attrs %{active: nil}

    def feature_configuration_fixture(attrs \\ %{}) do
      {:ok, feature_configuration} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Features.create_feature_configuration()

      feature_configuration
    end

    test "list_feature_configurations/0 returns all feature_configurations" do
      feature_configuration = feature_configuration_fixture()
      assert Features.list_feature_configurations() == [feature_configuration]
    end

    test "get_feature_configuration!/1 returns the feature_configuration with given id" do
      feature_configuration = feature_configuration_fixture()
      assert Features.get_feature_configuration!(feature_configuration.id) == feature_configuration
    end

    test "create_feature_configuration/1 with valid data creates a feature_configuration" do
      assert {:ok, %FeatureConfiguration{} = feature_configuration} = Features.create_feature_configuration(@valid_attrs)
      assert feature_configuration.active == true
    end

    test "create_feature_configuration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Features.create_feature_configuration(@invalid_attrs)
    end

    test "update_feature_configuration/2 with valid data updates the feature_configuration" do
      feature_configuration = feature_configuration_fixture()
      assert {:ok, feature_configuration} = Features.update_feature_configuration(feature_configuration, @update_attrs)
      assert %FeatureConfiguration{} = feature_configuration
      assert feature_configuration.active == false
    end

    test "update_feature_configuration/2 with invalid data returns error changeset" do
      feature_configuration = feature_configuration_fixture()
      assert {:error, %Ecto.Changeset{}} = Features.update_feature_configuration(feature_configuration, @invalid_attrs)
      assert feature_configuration == Features.get_feature_configuration!(feature_configuration.id)
    end

    test "delete_feature_configuration/1 deletes the feature_configuration" do
      feature_configuration = feature_configuration_fixture()
      assert {:ok, %FeatureConfiguration{}} = Features.delete_feature_configuration(feature_configuration)
      assert_raise Ecto.NoResultsError, fn -> Features.get_feature_configuration!(feature_configuration.id) end
    end

    test "change_feature_configuration/1 returns a feature_configuration changeset" do
      feature_configuration = feature_configuration_fixture()
      assert %Ecto.Changeset{} = Features.change_feature_configuration(feature_configuration)
    end
  end

  describe "feature_configurations" do
    alias Toggly.Features.FeatureConfiguration

    @valid_attrs %{is_active: true}
    @update_attrs %{is_active: false}
    @invalid_attrs %{is_active: nil}

    def feature_configuration_fixture(attrs \\ %{}) do
      {:ok, feature_configuration} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Features.create_feature_configuration()

      feature_configuration
    end

    test "list_feature_configurations/0 returns all feature_configurations" do
      feature_configuration = feature_configuration_fixture()
      assert Features.list_feature_configurations() == [feature_configuration]
    end

    test "get_feature_configuration!/1 returns the feature_configuration with given id" do
      feature_configuration = feature_configuration_fixture()
      assert Features.get_feature_configuration!(feature_configuration.id) == feature_configuration
    end

    test "create_feature_configuration/1 with valid data creates a feature_configuration" do
      assert {:ok, %FeatureConfiguration{} = feature_configuration} = Features.create_feature_configuration(@valid_attrs)
      assert feature_configuration.is_active == true
    end

    test "create_feature_configuration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Features.create_feature_configuration(@invalid_attrs)
    end

    test "update_feature_configuration/2 with valid data updates the feature_configuration" do
      feature_configuration = feature_configuration_fixture()
      assert {:ok, feature_configuration} = Features.update_feature_configuration(feature_configuration, @update_attrs)
      assert %FeatureConfiguration{} = feature_configuration
      assert feature_configuration.is_active == false
    end

    test "update_feature_configuration/2 with invalid data returns error changeset" do
      feature_configuration = feature_configuration_fixture()
      assert {:error, %Ecto.Changeset{}} = Features.update_feature_configuration(feature_configuration, @invalid_attrs)
      assert feature_configuration == Features.get_feature_configuration!(feature_configuration.id)
    end

    test "delete_feature_configuration/1 deletes the feature_configuration" do
      feature_configuration = feature_configuration_fixture()
      assert {:ok, %FeatureConfiguration{}} = Features.delete_feature_configuration(feature_configuration)
      assert_raise Ecto.NoResultsError, fn -> Features.get_feature_configuration!(feature_configuration.id) end
    end

    test "change_feature_configuration/1 returns a feature_configuration changeset" do
      feature_configuration = feature_configuration_fixture()
      assert %Ecto.Changeset{} = Features.change_feature_configuration(feature_configuration)
    end
  end
end
