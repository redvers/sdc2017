require Logger
defmodule SDC2017.Badge do
  use GenStateMachine, callback_mode: :handle_event_function

  def start_link(badgeid, ipport) do
    GenStateMachine.start_link(__MODULE__, %{id: badgeid, ipport: ipport, option: 0, fb: <<>>}, name: String.to_atom(badgeid))
  end

  def init(data) do
    Process.flag(:trap_exit, true)
    {:ok, :initial, data}
  end

  def handle_event(:cast, {:payload, "COLDBOOT", ipport}, state, data = %{id: badgeid}) do
    Logger.debug("#{badgeid} noapp")
    render_noapp(ipport, state, data)
  end
  def handle_event(:cast, {:payload, <<"BATT", _mV :: bytes-size(4)>>, ipport}, :initial, data), do: render_noapp(ipport, :initial, data)
  def handle_event(:cast, {:payload, <<"BATT", _mV :: bytes-size(4)>>, _ipport}, state, data), do: {:next_state, state, data}
  def handle_event(:cast, {:payload, "BD", {_ip, _uport}}, _state, data), do: render_menu(data)
  def handle_event(:cast, {:payload, "BU", {_ip, _uport}}, _state, data), do: switch_app(data)

  def handle_event(:cast, {:display, bindata}, SDC2017.Twitter, data = %{id: badgeid}) when is_binary(bindata) do
    GenServer.cast(SDC2017.UDP, {:display, badgeid, bindata})
    newdata = Map.put(data, :fb, bindata)
    {:next_state, SDC2017.Twitter, newdata}
  end
  def handle_event(:cast, {:display, _bindata}, state, data), do: {:next_state, state, data}

  def handle_event(:cast, {:payload, "DD", _ipport}, :menu, data = %{option: menuoption}) do
    newmenu = 
    case (menuoption > 2) do
      true -> 0
      false -> menuoption + 1
    end

    Map.put(data, :option, newmenu)
    |> render_menu
  end
  def handle_event(:cast, {:payload, "UD", _ipport}, :menu, data = %{option: menuoption}) do
    newmenu = 
    case (menuoption < 1) do
      true -> 3
      false -> menuoption - 1
    end

    Map.put(data, :option, newmenu)
    |> render_menu
  end
  def handle_event(:cast, {:payload, _, _ipport}, :menu, data), do: render_menu(data)

  def handle_event(:cast, {:payload, payload, ipport}, :initial, data), do: render_noapp(ipport, :initial, data)
  def handle_event(:cast, {:payload, payload, _ipport}, state, data = %{id: badgeid}) do
    newpid = 
    case Registry.match(:badgeapps, badgeid, state) do
      [] -> {:ok, pid} = apply(state, :start_link, [badgeid])
            pid
      [{pid, _appmodule}] -> pid
    end

#    IO.inspect(payload)

    bindata = GenServer.call(newpid, {:payload, payload})
    GenServer.cast(SDC2017.UDP, {:display, badgeid, bindata})
    newstate = Map.put(data, :fb, bindata)
    {:next_state, state, newstate}
  end

  def handle_event(eventtype = :cast, eventcontent, state, data) do
    IO.inspect(eventtype)
    IO.inspect(eventcontent)
    IO.inspect(state)
    IO.inspect(data)

    {:next_state, state, data}
  end
  
  def handle_event({:call, from}, _eventcontent, state, data) do
    {:next_state, state, data, [{:reply, from, <<>>}]}
  end

  def app(0), do: SDC2017.Twitter             # Test Application
  def app(1), do: SDC2017.Schedule         # Schedule
  def app(2), do: SDC2017.Twitter          # Twitter Feed
  def app(3), do: SDC2017.Twitter      # Compose Tweet


  def render_noapp({{a,b,c,d},port}, _state, data = %{id: badgeid}) do
    dt = DateTime.utc_now
         |> DateTime.to_string

    ddt = Regex.replace(~r/\..*/, dt, "", [])

    bindata = SDC2017.Tbox.cls
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "ID: #{badgeid}")
    |> SDC2017.Tbox.print(%{x: 0, y: 1}, "IP: #{a}.#{b}.#{c}.#{d}")
    |> SDC2017.Tbox.print(%{x: 0, y: 2}, "PT: #{port}")
    |> SDC2017.Tbox.print(%{x: 0, y: 4}, "Connected: evil.red")
    |> SDC2017.Tbox.print(%{x: 0, y: 6}, "Press \"B\" for menu")
    |> SDC2017.Tbox.print(%{x: 0, y: 7}, ddt)
#    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render

    GenServer.cast(SDC2017.UDP, {:display, badgeid, bindata})
    newstate = Map.put(data, :fb, bindata)
    {:next_state, :initial, newstate}
  end
  def render_menu(data = %{id: badgeid, option: menuoption}) do
    bindata = SDC2017.Tbox.cls
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "     Main Menu    ")
    |> SDC2017.Tbox.print(%{x: 0, y: 2}, "  Twitter Feed    ")
    |> SDC2017.Tbox.print(%{x: 0, y: 3}, "  Schedule        ")
    |> SDC2017.Tbox.print(%{x: 0, y: 4}, "  MOAR Twitter    ")
    |> SDC2017.Tbox.print(%{x: 0, y: 5}, "  EVEN MOAR Tweets")
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
      [{pid, _appmodule}] -> pid
    end

    Logger.debug("#{inspect(self())} BadgeID: #{badgeid} switched to #{inspect(appmodule)}")


    bindata = GenServer.call(mypid, {:payload, :refresh})
    newdata = Map.put(data, :fb, bindata)

    GenServer.cast(SDC2017.UDP, {:display, badgeid, bindata})
    {:next_state, appmodule, newdata}
  end
end
