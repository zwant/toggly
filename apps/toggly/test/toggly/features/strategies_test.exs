defmodule Toggly.StrategiesTest do
  use ExUnit.Case

  alias Toggly.Features.Strategies

  defmodule TestNeverAppliesStrategy do
    @behaviour Strategies.ActivationStrategy

    def name(), do: "Test1"
    def parameters(), do: %{}

    def applies_to?(_request) do
      false
    end
    def matches?(_request, _) do
      false
    end
  end

  defmodule TestAlwaysAppliesStrategy do
    @behaviour Strategies.ActivationStrategy

    def name(), do: "Test2"
    def parameters(), do: %{}

    def applies_to?(_request) do
      true
    end
    def matches?(_request, _) do
      false
    end
  end

  defmodule TestMultipleParamsStrategy do
    @behaviour Strategies.ActivationStrategy

    def name(), do: "MultipleParams"
    def parameters(), do: %{"1" => fn _x -> true end, "2" => fn _x -> true end, "3" => fn _x -> true end}

    def applies_to?(_request) do
      true
    end
    def matches?(_request, _) do
      false
    end
  end

  defmodule TestFailingParamValidationStrategy do
    @behaviour Strategies.ActivationStrategy

    def name(), do: "MultipleFailingParams"
    def parameters(), do: %{"true" => fn _x -> true end,
                            "false" => fn _x -> false end}

    def applies_to?(_request) do
      true
    end
    def matches?(_request, _) do
      false
    end
  end

  describe "activation strategy" do
    setup [:request_with_all_fields]

    test "Evaluate is true if request is NOT applicable", context do
      refute Strategies.ActivationStrategy.evaluate(TestNeverAppliesStrategy,
        context[:request],
        %{})
    end

    test "Evaluate checks match if request is applicable", context do
      refute Strategies.ActivationStrategy.evaluate(TestAlwaysAppliesStrategy,
        context[:request],
        %{})
    end

    test "param validation fails if not at least one required is set", _context do
      refute [TestMultipleParamsStrategy]
        |> Strategies.ActivationStrategy.validate_params?(%{"MultipleParams" => %{"svante" => "hej"}})
    end

    test "param validation fails if at least one required is set, and it evaluates to false", _context do
      refute [TestFailingParamValidationStrategy]
        |> Strategies.ActivationStrategy.validate_params?(%{"MultipleFailingParams" => %{"false" => "hej"}})
    end

    test "param validation works if at least one required is set, and it evaluates to true", _context do
      assert [TestFailingParamValidationStrategy]
        |> Strategies.ActivationStrategy.validate_params?(%{"MultipleFailingParams" => %{"true" => "hej"}})
    end

    test "param validation fails if many are set, and one evaluates to false", _context do
      refute [TestFailingParamValidationStrategy]
        |> Strategies.ActivationStrategy.validate_params?(%{"MultipleFailingParams" => %{"true" => "hej",
                                                                                         "false" => "hej"}})
    end
  end

  describe "username strategy" do
    setup [:request_with_all_fields]

    alias Toggly.Features.Strategies.UsernameStrategy

    test "name is correct" do
      assert UsernameStrategy.name() == "Username"
    end

    test "parameters are as expected" do
      assert %{"matches_exactly" => _} = UsernameStrategy.parameters()
    end

    test "applies to is true when request has a user with username", context do
      assert UsernameStrategy.applies_to?(context[:request])
    end

    test "applies to is false when request has a user but no username", context do
      request_with_empty_username = %{context[:request] | user: %{user_id: "1", username: "", region: "SE"}}
      refute UsernameStrategy.applies_to?(request_with_empty_username)

      request_with_nil_username = %{context[:request] | user: %{user_id: "1", region: "SE"}}
      refute UsernameStrategy.applies_to?(request_with_nil_username)
    end

    test "matches_exactly parameter matches when username is correct", context do
      assert UsernameStrategy.matches?(context[:request], %{"matches_exactly" => "svante"})
    end

    test "matches_exactly parameter does not match when username is wrong", context do
      refute UsernameStrategy.matches?(context[:request], %{"matches_exactly" => "sv"})
    end

    test "validates param correctly", _context do
      %{"matches_exactly" => validation_function} = UsernameStrategy.parameters()
      refute validation_function.("")
      assert validation_function.("svante")
    end
  end

  describe "timestamp strategy" do
    setup [:request_with_all_fields]

    alias Toggly.Features.Strategies.TimestampStrategy

    test "name is correct" do
      assert TimestampStrategy.name() == "Timestamp"
    end

    test "parameters are as expected" do
      assert %{"before" => _,
               "after" => _,
               "between" => _} = TimestampStrategy.parameters()
    end

    test "applies to is true when request has a timestamp", context do
      assert TimestampStrategy.applies_to?(context[:request])
    end

    test "applies to is false when request has no timestamp", context do
      request_with_empty_timestamp = %{context[:request] | timestamp: ""}
      refute TimestampStrategy.applies_to?(request_with_empty_timestamp)

      request_with_nil_timestamp = %{context[:request] | timestamp: nil}
      refute TimestampStrategy.applies_to?(request_with_nil_timestamp)
    end

    test "before parameter matches when timestamp is before it", context do
      assert TimestampStrategy.matches?(context[:request], %{"before" => "2015-01-23T23:51:07Z"})
    end

    test "before parameter does not match when timestamp is after it", context do
      refute TimestampStrategy.matches?(context[:request], %{"before" => "2015-01-23T23:49:07Z"})
    end

    test "after parameter matches when timestamp is after it", context do
      assert TimestampStrategy.matches?(context[:request], %{"after" => "2012-01-23T23:50:07Z"})
    end

    test "after parameter does not match when timestamp is before it", context do
      refute TimestampStrategy.matches?(context[:request], %{"after" => "2018-01-23T23:50:07Z"})
    end

    test "between parameter matches when timestamp is between before and after", context do
      assert TimestampStrategy.matches?(context[:request], %{"between" => %{"first" => "2015-01-23T23:50:01Z",
                                                                            "second" => "2015-01-23T23:50:15Z"}})
    end

    test "between parameter does not match when timestamp is not between before and after", context do
      refute TimestampStrategy.matches?(context[:request], %{"between" => %{"first" => "2017-01-23T23:50:07Z",
                                                                            "second" => "2018-01-23T23:50:07Z"}})
    end

    test "validates before param correctly", _context do
      %{"before" => validation_function} = TimestampStrategy.parameters()
      refute validation_function.("")
      assert validation_function.("2015-01-23T23:50:07Z")
    end

    test "validates after param correctly", _context do
      %{"after" => validation_function} = TimestampStrategy.parameters()
      refute validation_function.("")
      assert validation_function.("2015-01-23T23:50:07Z")
    end

    test "validates between param correctly", _context do
      %{"between" => validation_function} = TimestampStrategy.parameters()
      refute validation_function.(%{"first" => "hello"})
      refute validation_function.(%{"first" => "hello",
                                    "second" => "2015-01-23T23:50:07Z"})
      assert validation_function.(%{"first" => "2015-01-23T23:50:07Z",
                                    "second" => "2015-01-23T23:50:07Z"})
    end
  end


  defp request_with_all_fields(_context) do
    alias Toggly.Features.Request
    [request:  %Request{timestamp: "2015-01-23T23:50:07Z",
                       server_ip_address: "127.0.0.1",
                       user: %Request.User{user_id: "1",
                                           username: "svante",
                                           region: "SE"}}]
  end
end
