require Logger
defmodule SDC2017.TwitterSend do
  use GenServer

  def start_link(badgeid) do
    GenServer.start_link(__MODULE__, %{id: badgeid}, [])
  end

  def init(state = %{id: badgeid}) do
    Registry.register(:badgeapps, badgeid, __MODULE__)
    {:ok, state}
  end

  def handle_cast(:die, state) do
    {:stop, :normal, state}
  end

  def handle_call(ii = {:payload, payload}, _, state) do
    bindata = SDC2017.Tbox.cls
##    |> SDC2017.Tbox.print(%{x: 0, y: 0}, inspect(__MODULE__))
    |> SDC2017.Tbox.print(%{x: 0, y: 3}, "q w e r t y u i o p ")
    |> SDC2017.Tbox.print(%{x: 0, y: 4}, " a s d f g h j k l \\n")
    |> SDC2017.Tbox.print(%{x: 0, y: 5}, "  z x c v b n m , .  ")
    |> SDC2017.Tbox.print(%{x: 0, y: 6}, "SHFT @ # SPC DEL DONE")
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    {:reply, bindata, state}
  end

end
