defmodule FailerWeb.LiveViewCrashLoopLog do
  @moduledoc """
  Track `LiveView` crashes per session id
  Useful for killing sessions that are crash looping
  """
  use GenServer

  @ttl :timer.minutes(1)
  @max_crashes 5

  defmodule Log do
    defstruct [:session_id, :last_crash_timestamp, num_crashes: 1]

    def new(session_id) do
      %Log{session_id: session_id, last_crash_timestamp: DateTime.utc_now()}
    end
  end

  def start_link(opts \\ []) do
    opts = Keyword.merge([name: __MODULE__], opts)
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def init(state) do
    schedule_delete_expired()
    {:ok, state}
  end

  # Client API

  def crash_loop?(session_id) do
    GenServer.call(__MODULE__, {:crash_loop?, session_id})
  end

  def crash(session_id) do
    GenServer.cast(__MODULE__, {:crash, session_id})
  end

  def delete(session_id) do
    GenServer.cast(__MODULE__, {:delete, session_id})
  end

  # Internal API

  def handle_call({:crash_loop?, session_id}, _from, state) when is_map_key(state, session_id) do
    log = :maps.get(session_id, state)
    crash_loop? = not expired?(log) and log.num_crashes > @max_crashes
    {:reply, crash_loop?, state}
  end

  def handle_call({:crash_loop?, session_id}, _from, state) do
    {:reply, false, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast({:crash, session_id}, state) when is_map_key(state, session_id) do
    now = DateTime.utc_now()
    log = :maps.get(session_id, state)

    if expired?(log, now) do
      {:noreply, %{state | session_id => Log.new(session_id)}}
    else
      log = %{log | num_crashes: log.num_crashes + 1, last_crash_timestamp: now}
      {:noreply, %{state | session_id => log}}
    end
  end

  def handle_cast({:crash, session_id}, state) do
    log = Log.new(session_id)
    {:noreply, Map.put(state, session_id, log)}
  end

  def handle_cast({:delete, session_id}, state) do
    {:noreply, Map.delete(state, session_id)}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(:delete_expired, state) do
    now = DateTime.utc_now()
    state = Map.reject(state, fn {_id, log} -> expired?(log, now) end)

    schedule_delete_expired()
    {:noreply, state}
  end

  defp expired?(%Log{last_crash_timestamp: timestamp}, now \\ DateTime.utc_now()) do
    DateTime.diff(now, timestamp) > @tll
  end

  defp schedule_delete_expired() do
    Process.send_after(self(), :delete_expired, :timer.hours(1))
  end
end
