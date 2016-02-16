defmodule RateLimitDemo.PageController do
  use RateLimitDemo.Web, :controller

  def index(conn, _params) do
    RateLimitDemo.HitCounter.increment
    render conn, "index.html"
  end

end
