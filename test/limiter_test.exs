defmodule RateLimitServerTest do
  use ExUnit.Case
  doctest RateLimitDemo.Limiter
  alias RateLimitDemo.Limiter

  test "refilling from empty at 1 / second" do
    old_state = %{tokens: 0, last_updated_at: 0, rate: 1, unit: :second}
    new_state = Limiter.refill(old_state, 1000)
    assert new_state.tokens == 1
    assert new_state.last_updated_at == 1000
  end

  test "refilling before one unit of time has elapsed, 1 / second" do
    old_state = %{tokens: 0, last_updated_at: 0, rate: 1, unit: :second}
    new_state = Limiter.refill(old_state, 500)
    assert new_state.tokens == 0.5
    assert new_state.last_updated_at == 500
  end

  test "refilling before one unit of time has elapsed, 60 / hour" do
    old_state = %{tokens: 0, last_updated_at: 0, rate: 6, unit: :hour}

    one_minute = 1000 * 60
    new_state = Limiter.refill(old_state, one_minute)

    assert new_state.tokens == 0.1
    assert new_state.last_updated_at == one_minute
  end

  test "refilling when already full" do
    old_state = %{tokens: 1, last_updated_at: 0, rate: 1, unit: :second}
    new_state = Limiter.refill(old_state, 1000)
    assert new_state.tokens == 1
  end

  test "calculating wake-up time to when next token will arrive" do
    state = %{tokens: 0.7, rate: 1, unit: :second}
    assert_in_delta Limiter.ms_to_next_token(state), 300, 0.00000001

    state = %{tokens: 0.9, rate: 20, unit: :second}
    assert_in_delta Limiter.ms_to_next_token(state), 5, 0.00000001
  end

  test "calling functions with limits" do

  end
end
