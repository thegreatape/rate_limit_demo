defmodule RateLimitDemo.PageController do
  use RateLimitDemo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
