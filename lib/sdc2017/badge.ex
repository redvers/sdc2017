require Logger
defmodule SDC2017.Badge do
  use GenStateMachine, callback_mode: :handle_event_function

  def start_link(badgeid, ipport) do
    GenStateMachine.start_link(__MODULE__, %{id: badgeid, ipport: ipport, option: 0, fb: <<>>}, name: String.to_atom(badgeid))
  end

  def init(data) do
    {:ok, :initial, data}
  end

  def handle_event(:cast, {"COLDBOOT", ipport}, state, data), do: render_noapp(ipport, state, data)
  def handle_event(:cast, {<<"BATT", mV :: bytes-size(4)>>, ipport}, :initial, data), do: render_noapp(ipport, :initial, data)
  def handle_event(:cast, {<<"BATT", mV :: bytes-size(4)>>, ipport}, state, data), do: {:next_state, state, data}
  def handle_event(:cast, {"BD", {ip, uport}}, state, data), do: render_menu(data)
  def handle_event(:cast, {"BU", {ip, uport}}, state, data), do: switch_app(data)

  def handle_event(:cast, {:display, bindata}, SDC2017.Twitter, data = %{id: badgeid}) do
    GenServer.cast(SDC2017.UDP, {:display, badgeid, bindata})
    newdata = Map.put(data, :fb, bindata)
    {:next_state, SDC2017.Twitter, newdata}
  end

  def handle_event(:cast, {"DD", ipport}, :menu, data = %{option: menuoption}) do
    newmenu = 
    case (menuoption > 2) do
      true -> 0
      false -> menuoption + 1
    end

    Map.put(data, :option, newmenu)
    |> render_menu
  end
  def handle_event(:cast, {"UD", ipport}, :menu, data = %{option: menuoption}) do
    newmenu = 
    case (menuoption < 1) do
      true -> 3
      false -> menuoption - 1
    end

    Map.put(data, :option, newmenu)
    |> render_menu
  end
  def handle_event(:cast, {_, ipport}, :menu, data), do: render_menu(data)

  def handle_event(:cast, {payload, ipport}, state, data = %{id: badgeid}) do
    newpid = 
    case Registry.match(:badgeapps, badgeid, state) do
      [] -> {:ok, pid} = apply(state, :start_link, [badgeid])
            pid
      [{pid, appmodule}] -> pid
    end

    bindata = GenServer.call(newpid, {:payload, payload})
    GenServer.cast(SDC2017.UDP, {:display, badgeid, bindata})
    newstate = Map.put(data, :fb, bindata)
    {:next_state, state, newstate}
  end

  def app(0), do: SDC2017.Test             # Test Application
  def app(1), do: SDC2017.Schedule         # Schedule
  def app(2), do: SDC2017.Twitter          # Twitter Feed
  def app(3), do: SDC2017.TwitterSend      # Compose Tweet

  def handle_event(eventtype = :cast, eventcontent, state, data) do
    IO.inspect(eventtype)
    IO.inspect(eventcontent)
    IO.inspect(state)
    IO.inspect(data)

    {:next_state, state, data}
  end
  
  def handle_event(eventtype = {:call, from}, eventcontent, state, data) do
    {:next_state, state, data, [{:reply, from, <<>>}]}
  end

  def render_noapp(ipport = {{a,b,c,d},port}, state, data = %{id: badgeid}) do
    bindata = SDC2017.Tbox.cls
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "ID: #{badgeid}")
    |> SDC2017.Tbox.print(%{x: 0, y: 1}, "IP: #{a}.#{b}.#{c}.#{d}")
    |> SDC2017.Tbox.print(%{x: 0, y: 2}, "PT: #{port}")
    |> SDC2017.Tbox.print(%{x: 0, y: 4}, "Connected: evil.red")
    |> SDC2017.Tbox.print(%{x: 0, y: 6}, "Press \"B\" for menu")
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render

    GenServer.cast(SDC2017.UDP, {:display, badgeid, bindata})
    newstate = Map.put(data, :fb, bindata)
    {:next_state, :initial, newstate}
  end
  def render_menu(data = %{id: badgeid, ipport: ipport, option: menuoption}) do
    bindata = SDC2017.Tbox.cls
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "     Main Menu    ")
    |> SDC2017.Tbox.print(%{x: 0, y: 2}, "  Test Application")
    |> SDC2017.Tbox.print(%{x: 0, y: 3}, "  Schedule        ")
    |> SDC2017.Tbox.print(%{x: 0, y: 4}, "  Twitter Feed    ")
    |> SDC2017.Tbox.print(%{x: 0, y: 5}, "  Compose Tweet   ")
    |> SDC2017.Tbox.print(%{x: 0, y: (menuoption + 2)}, ">")
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render

    GenServer.cast(SDC2017.UDP, {:display, badgeid, bindata})
    newdata = Map.put(data, :fb, bindata)
    {:next_state, :menu, newdata}
  end

  def switch_app(data = %{id: badgeid, option: menuoption}) do
    appmodule = app(menuoption)
    mypid = 
    case Registry.match(:badgeapps, badgeid, appmodule) do
      [] -> {:ok, pid} = apply(appmodule, :start_link, [badgeid])
            pid
      [{pid, appmodule}] -> pid
    end

    Logger.debug("BadgeID: #{badgeid} switched to #{inspect(appmodule)}")


    bindata = GenServer.call(mypid, {:payload, :refresh})
    newdata = Map.put(data, :fb, bindata)

    GenServer.cast(SDC2017.UDP, {:display, badgeid, bindata})
    {:next_state, appmodule, newdata}
  end
end
