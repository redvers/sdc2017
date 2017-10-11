require Logger
defmodule Sdc2017.UDP do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, [name: :badgeUDP])
  end

  def init(nil) do
    {:ok, port} = :gen_udp.open(2391, [{:active, true}, :binary])
    {:ok, %{port: port}}
  end

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "COLDBOOT" >>}, state) do
    dispatch(:coldboot, badgeid, {ip, udpp}, state)
    {:noreply, state}
  end

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "U", "D" >>}, state), do: dispatch(:ud, badgeid,  {ip, udpp}, state)
  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "U", "U" >>}, state), do: dispatch(:uu, badgeid,  {ip, udpp}, state)

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "D", "D" >>}, state), do: dispatch(:dd, badgeid,  {ip, udpp}, state)
  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "D", "U" >>}, state), do: dispatch(:du, badgeid,  {ip, udpp}, state)

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "L", "D" >>}, state), do: dispatch(:ld, badgeid,  {ip, udpp}, state)
  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "L", "U" >>}, state), do: dispatch(:lu, badgeid,  {ip, udpp}, state)

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "R", "D" >>}, state), do: dispatch(:rd, badgeid,  {ip, udpp}, state)
  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "R", "U" >>}, state), do: dispatch(:ru, badgeid,  {ip, udpp}, state)

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "P", "D" >>}, state), do: dispatch(:pd, badgeid,  {ip, udpp}, state)
  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "P", "U" >>}, state), do: dispatch(:pu, badgeid,  {ip, udpp}, state)

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "B", "D" >>}, state), do: dispatch(:bd, badgeid,  {ip, udpp}, state)
  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "B", "U" >>}, state), do: dispatch(:bu, badgeid,  {ip, udpp}, state)

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "M", "K", other :: binary>>}, state), do: dispatch({:mk, other}, badgeid,  {ip, udpp}, state)

  def handle_info({:udp, _port, ip, udpp, << badgeid::bytes-size(10), "BATT", other :: binary>>}, state), do: dispatch({:batt, other}, badgeid,  {ip, udpp}, state)

  def handle_cast({:display, x = {ip,uport}, bindata}, state = %{port: port}) do
    :gen_udp.send(port, ip, uport, bindata)
    {:noreply, state}
  end

  def handle_cast(foo, state) do
    IO.inspect(foo)
    IO.inspect(state)
    {:noreply, state}
  end




  def dispatch(direction, badgeid, {ip, udpp}, state) do
    pid = findpid(badgeid, {ip, udpp})
    GenServer.cast(pid, {direction, {ip, udpp}})
    {:noreply, state}
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
