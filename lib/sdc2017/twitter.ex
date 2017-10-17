require Logger
defmodule SDC2017.Twitter do
  use GenServer

  def start_link(badgeid) do
    GenServer.start_link(__MODULE__, %{id: badgeid, tbox: SDC2017.Tbox.cls}, [])
  end

  def init(state = %{id: badgeid}) do
    Registry.register(:badgeapps, badgeid, __MODULE__)
    :timer.send_interval(1000, :ping)
    spawn_link(__MODULE__, :start_stream, [self])
    {:ok, state}
  end

  def handle_cast(:die, state) do
    {:stop, :normal, state}
  end

  def handle_call(ii = {:payload, payload}, _, state) do
    tbox = SDC2017.Tbox.cls
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "Twitter")
    |> SDC2017.Tbox.print(%{x: 0, y: 3}, "Please hold while")
    |> SDC2017.Tbox.print(%{x: 0, y: 4}, "we wait for tweets")
    |> SDC2017.Tbox.print(%{x: 0, y: 5}, "for #infosec")
    |> SDC2017.Tbox.pp

    bindata = SDC2017.OLED.render(tbox)
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    newstate = Map.put(state, :tbox, tbox)
    {:reply, bindata, newstate}
  end

  def start_stream(pid) do
    GenEvent.stream(SDC2017.TwitterStream)
    |> Stream.map(fn(tweet) -> GenServer.cast(pid, tweet) end)
    |> Stream.run
  end

  def handle_cast({:tweet, %{user: %{screen_name: user}, text: text}}, state) do
    newstate = render_model(user, text, state)
    {:noreply, newstate}
  end

  def render_model(user, text, state = %{id: badgeid}) do
    tbox = %SDC2017.Tbox{}
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "Twitter #infosec")
    |> SDC2017.Tbox.print(%{x: 0, y: 1}, "@#{sanitize(user)}:")
    |> SDC2017.Tbox.print(%{x: 0, y: 2}, "@#{sanitize(text)}:")

    img = SDC2017.OLED.render(tbox)

    badgepid = String.to_atom(badgeid)
    |> Process.whereis

    GenServer.cast(badgepid, {:display, img})

    Map.put(state, :tbox, tbox)
  end

  def sanitize(text) do
#    IO.puts(text)
    newtext =
    case :unicode.characters_to_binary(String.to_char_list(text), :latin1) do
      {:error, text, _} -> text
      text -> text
    end

    String.replace(newtext, ~r/\n/, "")
    |> String.replace("&amp", "&")
    |> String.replace("&gt", "<")
    |> String.replace("&lt", ">")
  end

  def handle_info(:ping, state = %{tbox: tbox, id: badgeid}) do
    dt = Time.utc_now
         |> Time.to_iso8601

    ddt = Regex.replace(~r/\..*/, dt, "")



    img = 
    SDC2017.Tbox.print(tbox, %{x: 13, y: 0}, ddt)
    |> SDC2017.OLED.render

    String.to_atom(badgeid)
    |> Process.whereis
    |> GenServer.cast({:display, img})
    
    {:noreply, state}
  end
  def handle_info(foo, state) do
    Logger.info(inspect(foo))
    {:noreply, state}
  end





end
