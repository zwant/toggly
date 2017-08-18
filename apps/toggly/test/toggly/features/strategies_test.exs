defmodule Toggly.StrategiesTest do
  use ExUnit.Case

  alias Toggly.Features.Strategies

  defmodule TestNeverAppliesStrategy do
    @behaviour Strategies.ActivationStrategy

    def name(), do: "Test1"
    def parameters(), do: []

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
    def parameters(), do: []

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
    def parameters(), do: [{"1", fn x -> true end}, {"2", fn x -> true end}, {"3", fn x -> true end}]

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
      assert Strategies.ActivationStrategy.evaluate(TestNeverAppliesStrategy,
        context[:request],
        %{}) == true
    end

    test "Evaluate checks match if request is applicable", context do
      assert Strategies.ActivationStrategy.evaluate(TestAlwaysAppliesStrategy,
        context[:request],
        %{}) == false
    end
  end

  describe "username strategy" do
    setup [:request_with_all_fields]

    alias Toggly.Features.Strategies.UsernameStrategy

    test "name is correct" do
      assert UsernameStrategy.name() == "Username"
    end

    test "parameters are as expected" do
      assert UsernameStrategy.parameters() == [{"matches_exactly", fn param -> String.length(param) > 0 end}]
    end

    test "applies to is true when request has a user with username", context do
      assert UsernameStrategy.applies_to?(context[:request]) == true
    end

    test "applies to is false when request has a user but no username", context do
      request_with_empty_username = %{context[:request] | user: %{user_id: "1", username: "", region: "SE"}}
      assert UsernameStrategy.applies_to?(request_with_empty_username) == false

      request_with_nil_username = %{context[:request] | user: %{user_id: "1", region: "SE"}}
      assert UsernameStrategy.applies_to?(request_with_nil_username) == false
    end

    test "matches_exactly parameter matches when username is correct", context do
      assert UsernameStrategy.matches?(context[:request], %{"matches_exactly" => "svante"}) == true
    end

    test "matches_exactly parameter does not match when username is wrong", context do
      assert UsernameStrategy.matches?(context[:request], %{"matches_exactly" => "sv"}) == false
    end
  end

  describe "timestamp strategy" do
    setup [:request_with_all_fields]

    alias Toggly.Features.Strategies.TimestampStrategy

    test "name is correct" do
      assert TimestampStrategy.name() == "Timestamp"
    end

    test "parameters are as expected" do
      assert TimestampStrategy.parameters() == ["before", "after", "between"]
    end

    test "applies to is true when request has a timestamp", context do
      assert TimestampStrategy.applies_to?(context[:request]) == true
    end

    test "applies to is false when request has no timestamp", context do
      request_with_empty_timestamp = %{context[:request] | timestamp: ""}
      assert TimestampStrategy.applies_to?(request_with_empty_timestamp) == false

      request_with_nil_timestamp = %{context[:request] | timestamp: nil}
      assert TimestampStrategy.applies_to?(request_with_nil_timestamp) == false
    end

    test "before parameter matches when timestamp is before it", context do
      assert TimestampStrategy.matches?(context[:request], %{"before" => "2016-01-23T23:50:07Z"}) == true
    end

    test "before parameter does not match when timestamp is after it", context do
      assert TimestampStrategy.matches?(context[:request], %{"before" => "2014-01-23T23:50:07Z"}) == false
    end

    test "after parameter matches when timestamp is after it", context do
      assert TimestampStrategy.matches?(context[:request], %{"after" => "2012-01-23T23:50:07Z"}) == true
    end

    test "after parameter does not match when timestamp is before it", context do
      assert TimestampStrategy.matches?(context[:request], %{"after" => "2018-01-23T23:50:07Z"}) == false
    end

    test "between parameter matches when timestamp is between before and after", context do
      assert TimestampStrategy.matches?(context[:request], %{"between" => %{"first" => "2012-01-23T23:50:07Z",
                                                                            "second" => "2018-01-23T23:50:07Z"}}) == true
    end

    test "between parameter does not match when timestamp is not between before and after", context do
      assert TimestampStrategy.matches?(context[:request], %{"between" => %{"first" => "2017-01-23T23:50:07Z",
                                                                            "second" => "2018-01-23T23:50:07Z"}}) == false
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
