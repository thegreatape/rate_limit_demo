defmodule RateLimitDemo.HitChannel do
  use Phoenix.Channel

  def join("hits", _message, socket) do
    {:ok, socket}
  end
end
