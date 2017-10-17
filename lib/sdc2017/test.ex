require Logger
defmodule SDC2017.Test do
  use GenServer

  def start_link(badgeid) do
    GenServer.start_link(__MODULE__, %{id: badgeid, tbox: SDC2017.Tbox.cls}, [])
  end

  def init(state = %{id: badgeid}) do
    Registry.register(:badgeapps, badgeid, __MODULE__)
    {:ok, Map.put(state, :culture, parse_culture())}
  end

  def handle_cast(:die, state) do
    {:stop, :normal, state}
  end

  def handle_call(ii = {:payload, payload}, _, state = %{tbox: tbox, culture: [line | rest]}) do
    IO.inspect(line)
    newtbox = 
    case line do
      [""] -> SDC2017.Tbox.crlf(tbox)
      words -> t =
               word = Enum.reject(words, &(&1 == ""))
                      |> Enum.join(" ")
               SDC2017.Tbox.print(tbox, word)

    end
#    |> SDC2017.Tbox.print(inspect(payload))
    |> SDC2017.Tbox.pp
    IO.inspect(newtbox)
    bindata = SDC2017.OLED.render(newtbox)
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    nstate = Map.put(state, :culture, rest)
    {:reply, bindata, Map.put(nstate, :tbox, newtbox)}
  end

  def parse_culture do
    File.read!("culture/son.txt")
    |> String.split("\n")
    |> Enum.map(&(String.split(&1, " ")))
  end



end
