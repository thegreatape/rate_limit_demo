defmodule RateLimitDemo.HitCounter do
  def start_link do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def increment do
    Agent.update(__MODULE__, fn val -> val + 1 end)
    RateLimitDemo.Endpoint.broadcast "hits","updated_hit_count", %{count: current_hits}
  end

  def current_hits do
    Agent.get(__MODULE__, &(&1))
  end
end
