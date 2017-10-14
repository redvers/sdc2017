require Logger
defmodule SDC2017.Twitter do
  use GenServer

  def start_link(badgeid) do
    GenServer.start_link(__MODULE__, %{id: badgeid}, [])
  end

  def init(state = %{id: badgeid}) do
    Registry.register(:badgeapps, badgeid, __MODULE__)
    spawn_link(__MODULE__, :start_stream, [self])
    {:ok, state}
  end

  def handle_cast(:die, state) do
    {:stop, :normal, state}
  end

  def handle_call(ii = {:payload, payload}, _, state) do
    bindata = SDC2017.Tbox.cls
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, inspect(__MODULE__))
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    {:reply, bindata, state}
  end

  def start_stream(pid) do
    GenEvent.stream(SDC2017.TwitterStream)
    |> Stream.map(fn(tweet) -> GenServer.cast(pid, tweet) end)
    |> Stream.run
  end

  def handle_cast({:tweet, %{user: %{screen_name: user}, text: text}}, state) do
    render_model(user, text, state)
    {:noreply, state}
  end

  def render_model(user, text, state = %{id: badgeid}) do
    img = %SDC2017.Tbox{}
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "Twitter #infosec")
    |> SDC2017.Tbox.print(%{x: 0, y: 1}, "@#{sanitize(user)}:")
    |> SDC2017.Tbox.print(%{x: 0, y: 2}, "@#{sanitize(text)}:")
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render

    String.to_atom(badgeid)
    |> Process.whereis
    |> GenServer.cast({:display, img})
  end

  def sanitize(text) do
    IO.puts(text)
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





end
