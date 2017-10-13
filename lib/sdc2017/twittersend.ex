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
    Logger.debug("#{inspect(__MODULE__)}: #{inspect(ii)}")
    {:reply, <<>>, state}
  end

end
