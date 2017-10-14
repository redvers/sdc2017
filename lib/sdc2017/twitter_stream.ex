require Logger
defmodule SDC2017.TwitterStream do
  use GenEvent

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)
    GenEvent.add_handler(pid, __MODULE__, 0)

    Application.get_env(:sdc2017, :twitter)
    |> ExTwitter.configure

    spawn_link(__MODULE__, :start_stream, [])

    {:ok, pid}
  end

  def handle_event(_foo, count) do
    {:ok, count+1}
  end

  def start_stream do
    ExTwitter.stream_filter(track: "#infosec")
    |> Stream.map(fn(ev) -> GenEvent.notify(__MODULE__, {:tweet, ev}) end)
    |> Stream.run
  end

end
