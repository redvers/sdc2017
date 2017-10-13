require Logger
defmodule SDC2017.Schedule do
  use GenServer

  def start_link(badgeid) do
    GenServer.start_link(__MODULE__, %{id: badgeid, day: 0, location: 0}, [])
  end

  def init(state = %{id: badgeid}) do
    Registry.register(:badgeapps, badgeid, __MODULE__)
    {:ok, state}
  end

  def handle_cast(:die, state) do
    {:stop, :normal, state}
  end

  def handle_call(ii = {:payload, "DD"}, _, state = %{day: day}) do
    newday =
      case (day > 4) do
        true -> 0
        false -> day + 1
      end
    newstate = Map.put(state, :day, newday)
    bindata = header(newstate)
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    {:reply, bindata, newstate}
  end
  def handle_call(ii = {:payload, "UD"}, _, state = %{day: day}) do
    newday =
      case (day == 0) do
        true -> 1
        false -> day - 1
      end
    newstate = Map.put(state, :day, newday)
    bindata = header(newstate)
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    {:reply, bindata, newstate}
  end




  def handle_call(ii = {:payload, payload}, _, state) do
    bindata = header(state)
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    {:reply, bindata, state}
  end

  def header(state) do
    SDC2017.Tbox.cls
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "SkyDogCon Schedule")
    |> daytime(state.day, state.location)
  end

  def daytime(tbox,day,location) do
    tbox
    |> SDC2017.Tbox.print(%{x: 0, y: 1}, dayname(day,location))
  end

### Thursday
  def dayname(0,_), do: "Location: Everywhere " <>
                        "Thu **:** -> 19:00   " <>
                        "                     " <>
                        "Event Setup"
  def dayname(1,_), do: "Location: Everywhere " <>
                        "Thu 19:00 -> 23:00   " <>
                        "                     " <>
                        "Pre-con hangouts and " <>
                        "informal activities. " <>
                        "(20:00 Earlybird +   " <>
                        "speaker drop-in)"

### Friday
  def dayname(2,_), do: "Location: Everywhere " <>
                        "Fri 08:00 -> **:**   " <>
                        "                     " <>
                        "Registration"
  def dayname(3,_), do: "Location: Track 1    " <>
                        "Fri 09:00 -> 10:00   " <>
                        "                     " <>
                        "OpeningRemarks SkyDog" <>
                        "                     " <>
                        "IntroCTF: @jamesbower" <>
                        "Teh Gamez: @ruff_tr  "
  def dayname(4,_), do: "Location: Track 1    " <>
                        "Fri 10:00 -> 11:00   " <>
                        "                     " <>
                        "Curtis Koening       " <>
                        "                     " <>
                        "Training Everyone to " <>
                        "lead"
  def dayname(5,_), do: "Location: Track 1    " <>
                        "Fri 11:00 -> 12:00   " <>
                        "                     " <>
                        "James \"GreyRaven\"    " <>
                        "Powel                " <>
                        "                     " <>
                        "Overkill:Home Edition"
             

end

