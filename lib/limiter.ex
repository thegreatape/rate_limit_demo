defmodule RateLimitDemo.Limiter do
  use GenServer
  alias Timex.Time

  def start_link(name, params) do
    GenServer.start_link(__MODULE__, params, name: name)
  end

  def invoke(server, module, func, args) do
    GenServer.call(server, {:invoke, module, func, args})
  end

  def check_queue(server) do
    GenServer.call(server, :check_queue)
  end

  def ms_to_next_token(state) do
    needed_fractional_token = 1.0 - (state.tokens - Float.floor(state.tokens))
    fractional_arrival_rate = unit_to_ms(state.unit) / state.rate

    round(needed_fractional_token * fractional_arrival_rate)
  end

  def refill(state, current_time) do
    delta_time = current_time - state.last_updated_at
    new_tokens = (state.rate * delta_time) / unit_to_ms(state.unit)
    tokens = Enum.min([state.rate, state.tokens + new_tokens])

    %{state | tokens: tokens, last_updated_at: current_time}
  end

  def work(state) do
    if state.tokens >= 1 do
      state = case state.queue do
        [{module, func, args} | rest] ->
          state = %{state | tokens: state.tokens - 1.0, queue: rest}
          spawn(module, func, args)
          work(state)
        [] -> state
      end
    else
      # schedule wake-up in time to next token
      :timer.apply_after(ms_to_next_token(state), __MODULE__, :check_queue, [self])
    end
    state
  end

  def unit_to_ms(unit) do
    case unit do
      :millisecond -> 1.0
      :second      -> 1000.0
      :minute      -> 60000.0
      :hour        -> 3600000.0
    end
  end

  #
  # GenServer callbacks
  #

  def init(params) do
    {:ok, Map.merge(params, %{tokens: params[:rate], queue: [], last_updated_at: Time.now(:msecs)})}
  end

  def handle_call(:check_queue, _form, state) do
    state = state
            |> refill(Time.now(:msecs))
            |> work
    {:reply, :ok, state}
  end

  def handle_call({:invoke, module, func, args}, _from, state) do
    state = %{state | queue: Enum.concat(state.queue, [{module, func, args}])}
    state = state
            |> refill(Time.now(:msecs))
            |> work

    {:reply, state, state}
  end
end
