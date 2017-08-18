defmodule Toggly.Features.Strategies do
  alias Toggly.Features.Request
  require Logger

  defmodule ActivationStrategy do
    @callback name() :: String.t()
    @callback parameters() :: [{String.t(), (%{} -> boolean)}]
    @callback matches?(request :: Request.t(), parameters :: %{}) :: boolean
    @callback applies_to?(request :: Request.t()) :: boolean

    def validate_params?(strategies, parameters) do
      Enum.all?(strategies,
        fn str ->
          Enum.all?(str.parameters(),
            fn { param_name, the_function } ->
              set_params_for_this_strat = Map.get(parameters, str.name(), %{})
              case Map.has_key?(parameters, param_name) do
                true -> the_function.(set_params_for_this_strat[param_name])
                false -> true
              end
            end)
        end)
    end

    def evaluate(strategy, request, parameters) do
      if strategy.applies_to?(request) do
        Logger.info("Strategy #{strategy.name()} applicable for request")
        strategy.matches?(request, Map.get(parameters, strategy.name(), %{}))
      else
        Logger.info("Strategy #{strategy.name()} NOT applicable for request")
        true
      end
    end
  end

  defmodule UsernameStrategy do
    @behaviour ActivationStrategy

    def name(), do: "Username"
    def parameters(), do: [{"matches_exactly", fn param -> String.length(param) > 0 end}]

    def applies_to?(request) do
      username = (request |> Map.get(:user, %{}) |> Map.get(:username))
      not username in [nil, ""]
    end
    def matches?(request, %{"matches_exactly" => exact_match}) do
      request.user.username == exact_match
    end
  end

  defmodule TimestampStrategy do
    @behaviour ActivationStrategy

    def name(), do: "Timestamp"
    def parameters(), do: ["before", "after", "between"]

    def applies_to?(request) do
      not request.timestamp in [nil, ""]
    end
    def matches?(request, %{"before" => before_time}) do
      {:ok, parsed_before_time} = Calendar.DateTime.Parse.rfc3339_utc(before_time)
      {:ok, parsed_request_time} = Calendar.DateTime.Parse.rfc3339_utc(request.timestamp)
      parsed_request_time |> Calendar.Date.before?(parsed_before_time)
    end

    def matches?(request, %{"after" => after_time}) do
      {:ok, parsed_after_time} = Calendar.DateTime.Parse.rfc3339_utc(after_time)
      {:ok, parsed_request_time} = Calendar.DateTime.Parse.rfc3339_utc(request.timestamp)
      parsed_request_time |> Calendar.Date.after?(parsed_after_time)
    end

    def matches?(request, %{"between" => %{"first" => first_time, "second" => second_time}}) do
      {:ok, parsed_first_time} = Calendar.DateTime.Parse.rfc3339_utc(first_time)
      {:ok, parsed_second_time} = Calendar.DateTime.Parse.rfc3339_utc(second_time)
      {:ok, parsed_request_time} = Calendar.DateTime.Parse.rfc3339_utc(request.timestamp)

      parsed_request_time |> Calendar.Date.after?(parsed_first_time)
        && parsed_request_time |> Calendar.Date.before?(parsed_second_time)
    end
  end

  defmacro __using__(_opts) do
    quote do
      import ActivationStrategy
      import UsernameStrategy
      import TimestampStrategy
    end
  end

  @all_strategies [UsernameStrategy, TimestampStrategy]

  def get_all() do
    @all_strategies
  end
end
