defmodule TogglyAdmin.PageController do
  use TogglyAdmin, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
