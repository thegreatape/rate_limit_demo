defmodule RateLimitDemo.PageController do
  use RateLimitDemo.Web, :controller
  alias RateLimitDemo.HitCounter
  alias RateLimitDemo.Limiter

  def index(conn, _params) do
    #HitCounter.increment
    Limiter.invoke(:one_per_second, HitCounter, :increment, [])
    render conn, "index.html"
  end

end
