defmodule RateLimitDemo.PageView do
  use RateLimitDemo.Web, :view

  def current_hits do
    RateLimitDemo.HitCounter.current_hits
  end
end
