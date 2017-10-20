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
      case (day > 22) do
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
        true -> 23
        false -> day - 1
      end
    newstate = Map.put(state, :day, newday)
    bindata = header(newstate)
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    {:reply, bindata, newstate}
  end


  def handle_call(ii = {:payload, "LD"}, _, state = %{location: location}) do
    newloc =
      case (location == 0) do
        true -> 1
        false -> location - 1
      end
    newstate = Map.put(state, :location, newloc)
    bindata = header(newstate)
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    {:reply, bindata, newstate}
  end
  def handle_call(ii = {:payload, "RD"}, _, state = %{location: location}) do
    newloc =
      case (location == 1) do
        true -> 0
        false -> location + 1
      end
    newstate = Map.put(state, :location, newloc)
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

  def dayname(6,_), do: "Location: Track 1    " <>
                        "Fri 12:00 -> 13:00   " <>
                        "                     " <>
                        "Lunch!               " <>
                        "                     " <>
                        "Not Smashburger      " <>
                        "#TrevorForget        "

  def dayname(7,_), do: "Location: Track 1    " <>
                        "Fri 13:00 -> 14:00   " <>
                        "                     " <>
                        "Rich MacVarish       " <>
                        "Crowdsourced Disaster" <>
                        "Response: Hurricane  " <>
                        "Harvey"

  def dayname(8,_), do: "Location: Track 1    " <>
                        "Fri 14:00 -> 15:00   " <>
                        "                     " <>
                        "FBI                  " <>
                        "                     " <>
                        "State of Insanity    "

  def dayname(9,_), do: "Location: Track 1    " <>
                        "Fri 15:00 -> 16:00   " <>
                        "                     " <>
                        "Joe Gray             " <>
                        "                     " <>
                        "Better OSINT for     " <>
                        "better SocEngineering"

  def dayname(10,_),do: "Location: Track 1    " <>
                        "Fri 16:00 -> 17:00   " <>
                        "Wally Prather        " <>
                        "Dave Marcus          " <>
                        "                     " <>
                        "DNC Leak in hands of " <>
                        "trained intel profess"

  def dayname(11,_),do: "Location: Track 1    " <>
                        "Fri 17:00 -> 18:00   " <>
                        "                     " <>
                        "Madmex               " <>
                        "                     " <>
                        "9 ways your SOC is   " <>
                        "failing              "

  def dayname(12,_),do: "Location: Track 1    " <>
                        "Fri 18:00 -> 19:00   " <>
                        "                     " <>
                        "Jayson Street        " <>
                        "                     " <>
                        "KEYNOTE              " 

  def dayname(13,_),do: "Location: Track 1    " <>
                        "Fri 19:00 -> **:**   " <>
                        "                     " <>
                        "Go Eat"

##### Saturday
  def dayname(15,1),do: "Location: Track 2    " <>
                        "Fri 10:00 -> 12:00   " <>
                        "                     " <>
                        "Marcelle             " <>
                        "                     " <>
                        "Fun with network     " <>
                        "traffic analysis     "
  def dayname(16,1),do: "Location: Track 2    " <>
                        "Fri 10:00 -> 12:00   " <>
                        "                     " <>
                        "Marcelle             " <>
                        "                     " <>
                        "Fun with network     " <>
                        "traffic analysis     "




  def dayname(14,_),do: "Location: Everywhere " <>
                        "Sat 09:00 -> 10:00   " <>
                        "                     " <>
                        "Registration Opens   " 

  def dayname(15,_),do: "Location: Track 1    " <>
                        "Sat 10:00 -> 11:00   " <>
                        "                     " <>
                        "Bob Wheeler          " <>
                        "                     " <>
                        "Finding your next    " <>
                        "Cybersec Job         "

  def dayname(16,_),do: "Location: Track 1    " <>
                        "Sat 11:00 -> 12:00   " <>
                        "                     " <>
                        "James Bower          " <>
                        "                     " <>
                        "Pen testing is dead, " <>
                        "adapt or demise      "

  def dayname(17,_),do: "Location: Track 1    " <>
                        "Sat 12:00 -> 13:00   " <>
                        "                     " <>
                        "Go Eat               " <>
                        "                     "

  def dayname(18,1),do: "Location: Track 2    " <>
                        "Sat 13:00 -> 17:00   " <>
                        "                     " <>
                        "Fuzzing Workshop     "
  def dayname(19,1),do: "Location: Track 2    " <>
                        "Sat 13:00 -> 17:00   " <>
                        "                     " <>
                        "Fuzzing Workshop     "
  def dayname(20,1),do: "Location: Track 2    " <>
                        "Sat 13:00 -> 17:00   " <>
                        "                     " <>
                        "Fuzzing Workshop     "
  def dayname(21,1),do: "Location: Track 2    " <>
                        "Sat 13:00 -> 17:00   " <>
                        "                     " <>
                        "Fuzzing Workshop     "
  def dayname(22,1),do: "Location: Track 2    " <>
                        "Sat 17:00 -> 17:00   " <>
                        "                     " <>
                        "David Ermer          " <>
                        "                     " <>
                        "Body channel         " <>
                        "communication        "

  def dayname(18,_),do: "Location: Track 2    " <>
                        "Sat 13:00 -> 14:00   " <>
                        "                     " <>
                        "Antonio Rucci        " <>
                        "                     " <>
                        "Breaking $#!+ with   " <>
                        "passive net assess   "

  def dayname(19,_),do: "Location: Track 1    " <>
                        "Sat 14:00 -> 15:00   " <>
                        "                     " <>
                        "Catatonic Prime      " <>
                        "                     " <>
                        "SSH, MSF, TOR, anon  " <>
                        "remote shells"

  def dayname(20,_),do: "Location: Track 1    " <>
                        "Sat 15:00 -> 16:00   " <>
                        "                     " <>
                        "Grid                 " <>
                        "                     " <>
                        "Anti-OSINT, or how to" <>
                        "hide from the man    "

  def dayname(21,_),do: "Location: Track 1    " <>
                        "Sat 16:00 -> 17:00   " <>
                        "                     " <>
                        "Russell Butrini      " <>
                        "                     " <>
                        "ImplementingMicrosoft" <>
                        "Adv Threat Analytics "

  def dayname(22,_),do: "Location: Track 1    " <>
                        "Sat 17:00 -> 18:00   " <>
                        "                     " <>
                        "l0stkn0wledge        " <>
                        "                     " <>
                        "Death of an Infosec  " <>
                        "Professional         "

  def dayname(23,_),do: "Location: Track 1    " <>
                        "Sat 18:00 -> 19:00   " <>
                        "                     " <>
                        "Scotty Moulton       " <>
                        "                     " <>
                        "KEYNOTE              "
             

end

