defmodule FailerWeb.PageController do
  use FailerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
