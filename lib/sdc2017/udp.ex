require Logger
defmodule SDC2017.UDP do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
  end

  def init(nil) do
    {:ok, port} = :gen_udp.open(2391, [{:active, true}, :binary])
    {:ok, %{port: port, badgesources: %{}}}
  end

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), payload :: binary >>}, state) do
    dispatch(payload, badgeid, {ip, udpp}, state)
  end

  def handle_cast({:display, badgeid, bindata}, state = %{port: port}) do
    {ip, uport} = Map.get(state.badgesources, badgeid, {{127,0,0,1}, 42})
    :gen_udp.send(port, ip, uport, bindata)
    {:noreply, state}
  end

  def handle_cast(foo, state) do
    IO.inspect(foo)
    IO.inspect(state)
    {:noreply, state}
  end

  def dispatch(payload, badgeid, {ip, udpp}, state) do
    pid = findpid(badgeid, {ip, udpp})
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(payload)}")
    GenServer.cast(pid, {payload, {ip, udpp}})
    newbadgesources = Map.put(state.badgesources, badgeid, {ip, udpp})
    {:noreply, Map.put(state, :badgesources, newbadgesources)}
  end

  def findpid(badgeid, ipport) do
    case SDC2017.Badge.start_link(badgeid, ipport) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def handle_info(foo, state) do
    Logger.debug(inspect(foo))
    {:noreply, state}
  end


end
