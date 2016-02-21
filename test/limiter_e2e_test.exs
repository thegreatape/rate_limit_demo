defmodule RateLimitE2ETest do
  use ExUnit.Case
  doctest RateLimitDemo.Limiter
  alias RateLimitDemo.Limiter
  alias RateLimitDemo.HitCounter

  test "rate limiting calls to a hit counter" do
    HitCounter.reset
    {:ok, limiter} = Limiter.start_link(:test_limiter, %{rate: 1, unit: :second})
    for _ <- (1..10) do
      Limiter.invoke(limiter, HitCounter, :increment, [])
    end

    # one tick at 0 seconds, 1 second, 2 seconds
    :timer.sleep(2500)
    assert HitCounter.current_hits == 3
  end
end
