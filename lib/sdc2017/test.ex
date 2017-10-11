require Logger
defmodule SDC2017.Test do
  use GenServer

  def start_link(badgeid) do
    GenServer.start_link(__MODULE__, %{id: badgeid,
      bstate: %{b: true,
               up: false,
             down: false,
             left: false,
            right: false,
             push: false}}, name: {:via, Registry, {:badgeapps, badgeid}})
  end

  def handle_cast(:die, state) do
    {:stop, :normal, state}
  end


  def handle_call(:bd, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :b, true)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end
  def handle_call(:bu, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :b, false)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:ud, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :up, true)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:uu, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :up, false)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:dd, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :down, true)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:du, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :down, false)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:ld, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :left, true)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:lu, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :left, false)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:rd, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :right, true)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:ru, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :right, false)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:pd, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :push, true)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end

  def handle_call(:pu, _, state = %{id: badgeid, bstate: bstate}) do
    newbstate = Map.put(bstate, :push, false)
    bindata = render_screen(badgeid, newbstate)
    {:reply, bindata, %{id: badgeid, bstate: newbstate}}
  end









  def render_screen(badgeid,bstate) do
    tb =
       SDC2017.Tbox.cls
    |> SDC2017.Tbox.print(%{x: 0, y: 0}, "ID: #{badgeid}")
    |> SDC2017.Tbox.print(%{x: 0, y: 7}, inspect(bstate))
    |> SDC2017.Tbox.pp
    |> SDC2017.OLED.render
  end






end
