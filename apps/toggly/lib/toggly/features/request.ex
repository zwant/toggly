defmodule Toggly.Features.Request do
  alias Toggly.Features.Request

  defmodule User do
    @enforce_keys [:user_id]
    defstruct user_id: nil, username: nil, region: nil

    @type t(user_id, username, region) :: %User{user_id: user_id, username: username, region: region}
    @type t :: %User{user_id: String.t, username: String.t, region: String.t}

    defimpl String.Chars, for: User do
      def to_string(user), do: "RequestUser{user_id: #{user.user_id}, username: #{user.username}, region: #{user.region}}"
    end
  end

  @enforce_keys [:timestamp]
  defstruct timestamp: nil, user: nil, server_ip_address: nil

  @type t(timestamp, user, server_ip_address) :: %Request{timestamp: timestamp,
                                                          user: user,
                                                          server_ip_address: server_ip_address}

  @type t :: %Request{timestamp: String.t, user: User.t, server_ip_address: String.t}

  defimpl String.Chars, for: Request do
    def to_string(request), do: "Request{timestamp: #{request.timestamp}, user: #{request.user}, server_ip_address: #{request.server_ip_address}}"
  end

end
