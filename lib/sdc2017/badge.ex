require Logger
defmodule SDC2017.Badge do
  use GenServer
  #  Responsible for:
  #    * Registration
  #    * Ping / Keepalive
  #    * Name / Handle

  def app_pid(badgeid) do
    case SDC2017.Test.start_link(badgeid) do
      {:ok, pid}                        -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def start_link(badgeid, ipport) do
    GenServer.start_link(__MODULE__, %{id: badgeid, ipport: ipport}, name: String.to_atom(badgeid))
  end

  def handle_cast({:coldboot, {ip = {a,b,c,d}, port}}, state = %{id: badgeid}) do
    bindata = SDC2017.Tbox.cls
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "ID: #{badgeid}")
    |> SDC2017.Tbox.print(%{x: 0, y: 1}, "IP: #{a}.#{b}.#{c}.#{d}")
    |> SDC2017.Tbox.print(%{x: 0, y: 2}, "PT: #{port}")
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render

    case Registry.lookup(:badgeapps, badgeid) do
      [{pid, nil}] -> GenServer.cast(pid, :die)
      [] -> nil
    end

    GenServer.cast(:badgeUDP, {:display, {ip, port}, bindata})
    {:noreply, %{id: badgeid, ipport: {ip, port}, fb: bindata}}
  end

  def handle_cast({{:mk, << scancode :: binary-size(2), "\r\n">>}, {ip, uport}}, state) do
    character = decode_scancode(scancode)
    |> Logger.debug
    {:noreply, state}
  end

  def handle_cast({{:batt, mV}, {ip, uport}}, state = %{fb: bindata}) do
    GenServer.cast(:badgeUDP, {:display, {ip, uport}, bindata})
    Logger.debug("UDP keepalive, PS: #{mV}mV")
    {:noreply, state}
  end

  def handle_cast({dir, {ipaddr, uport}},state = %{id: badgeid}) do
    Logger.debug(inspect(dir))
    bindata = GenServer.call(app_pid(badgeid), dir) 
    GenServer.cast(:badgeUDP, {:display, {ipaddr, uport}, bindata})
    {:noreply, %{id: badgeid, ipport: {ipaddr, uport}, fb: bindata}}
  end



  def handle_cast(foo,state) do
    Logger.debug(inspect(foo))
    {:noreply, state}
  end

  

  def decode_scancode("11"), do: "q"
  def decode_scancode("12"), do: "w"
  def decode_scancode("13"), do: "e"
  def decode_scancode("14"), do: "r"
  def decode_scancode("15"), do: "t"
  def decode_scancode("16"), do: "y"
  def decode_scancode("17"), do: "u"
  def decode_scancode("18"), do: "i"
  def decode_scancode("19"), do: "o"
  def decode_scancode("1A"), do: "p"


  def decode_scancode("1F"), do: "a"
  def decode_scancode("20"), do: "s"
  def decode_scancode("21"), do: "d"
  def decode_scancode("22"), do: "f"
  def decode_scancode("23"), do: "g"
  def decode_scancode("24"), do: "h"
  def decode_scancode("25"), do: "j"
  def decode_scancode("26"), do: "k"
  def decode_scancode("27"), do: "l"
  def decode_scancode("28"), do: "skip"
  def decode_scancode("29"), do: "\n"


  def decode_scancode("2D"), do: "z"
  def decode_scancode("2E"), do: "x"
  def decode_scancode("2F"), do: "c"
  def decode_scancode("30"), do: "v"
  def decode_scancode("31"), do: "b"
  def decode_scancode("32"), do: "n"
  def decode_scancode("33"), do: "m"
  def decode_scancode("34"), do: ","
  def decode_scancode("35"), do: "."
  def decode_scancode("36"), do: "bksp"
  def decode_scancode("37"), do: "alpha"

  def decode_scancode("02"), do: "hex"
  def decode_scancode("03"), do: "@"
  def decode_scancode("04"), do: "%"
  def decode_scancode("05"), do: "*"
  def decode_scancode("06"), do: "<"
  def decode_scancode("07"), do: "fieldcor"
  def decode_scancode("08"), do: "dup"
  def decode_scancode("09"), do: "-"
  def decode_scancode("0A"), do: "/"
  def decode_scancode("0B"), do: "charadv"
  def decode_scancode("0C"), do: "recadv"
  def decode_scancode("1B"), do: "fieldadv"
  def decode_scancode("0D"), do: "selprog"

  def decode_scancode("3C"), do: " "
  def decode_scancode(foo), do: foo



end
