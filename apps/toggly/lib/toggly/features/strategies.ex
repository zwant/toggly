defmodule Toggly.Features.Strategies do
  alias Toggly.Features.Request
  require Logger

  defmodule ActivationStrategy do
    @callback name() :: String.t()
    @callback parameters() :: %{required(String.t()) => (%{} -> boolean)}
    @callback matches?(request :: Request.t(), parameters :: %{}) :: boolean
    @callback applies_to?(request :: Request.t()) :: boolean

    def validate_params?(strategies, parameters) do
      strategies
        |> Enum.all?(fn str ->
          set_strat_params = parameters |> Map.get(str.name(), %{})
          str.parameters() |> Map.keys |> Enum.any?(fn x -> set_strat_params |> Map.has_key?(x) end) &&
            str.parameters() |> Enum.all?(&validate_single_param(&1, set_strat_params))
        end)
    end

    defp validate_single_param({param_name, the_function}, params) do
      case Map.has_key?(params, param_name) do
        true -> the_function.(params[param_name])
        false -> true
      end
    end

    def evaluate(strategy, request, parameters) do
      if strategy.applies_to?(request) do
        Logger.info("Strategy #{strategy.name()} applicable for request")
        strategy.matches?(request, Map.get(parameters, strategy.name(), %{}))
      else
        Logger.info("Strategy #{strategy.name()} NOT applicable for request")
        false
      end
    end
  end

  defmodule UsernameStrategy do
    @behaviour ActivationStrategy

    def name(), do: "Username"
    def parameters(), do: %{"matches_exactly" => fn param -> String.length(param) > 0 end,
                            "matches_regexp" => fn param -> String.length(param) > 0 && regex?(param) end}

    defp regex?(string_param) do
      case Regex.compile(string_param) do
        {:ok, _} -> true
        _ -> false
      end
    end
    def applies_to?(request) do
      username = (request |> Map.get(:user, %{}) |> Map.get(:username))
      not username in [nil, ""]
    end

    def matches?(request, %{"matches_exactly" => exact_match}) do
      request.user.username == exact_match
    end

    def matches?(request, %{"matches_regexp" => regex_string}) do
      Regex.compile!(regex_string) |> Regex.match?(request.user.username)
    end
  end

  defmodule TimestampStrategy do
    @behaviour ActivationStrategy

    defp validate_date_string(value) do
      {result, _} = Calendar.DateTime.Parse.rfc3339_utc(value)
      result == :ok
    end

    def name(), do: "Timestamp"
    def parameters(), do: %{"before" => &validate_date_string/1,
                            "after" => &validate_date_string/1,
                            "between" => fn param -> param |> Map.get("first", "") |> validate_date_string &&
                                                       param |> Map.get("second", "") |> validate_date_string end}

    def applies_to?(request) do
      not request.timestamp in [nil, ""]
    end
    def matches?(request, %{"before" => before_time}) do
      {:ok, parsed_before_time} = Calendar.DateTime.Parse.rfc3339_utc(before_time)
      {:ok, parsed_request_time} = Calendar.DateTime.Parse.rfc3339_utc(request.timestamp)
      parsed_request_time |> Calendar.DateTime.before?(parsed_before_time)
    end

    def matches?(request, %{"after" => after_time}) do
      {:ok, parsed_after_time} = Calendar.DateTime.Parse.rfc3339_utc(after_time)
      {:ok, parsed_request_time} = Calendar.DateTime.Parse.rfc3339_utc(request.timestamp)
      parsed_request_time |> Calendar.DateTime.after?(parsed_after_time)
    end

    def matches?(request, %{"between" => %{"first" => first_time, "second" => second_time}}) do
      {:ok, parsed_first_time} = Calendar.DateTime.Parse.rfc3339_utc(first_time)
      {:ok, parsed_second_time} = Calendar.DateTime.Parse.rfc3339_utc(second_time)
      {:ok, parsed_request_time} = Calendar.DateTime.Parse.rfc3339_utc(request.timestamp)

      parsed_request_time |> Calendar.DateTime.after?(parsed_first_time)
        && parsed_request_time |> Calendar.DateTime.before?(parsed_second_time)
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
