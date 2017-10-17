require Bitwise
defmodule SDC2017.OLED do
  use GenServer

  def start_link({128,64}) do
    GenServer.start_link(__MODULE__, {128,64}, name: :oledsrv128x64)
  end

  def init({128,64}) do
    fontname = :egd_font.load('fonts/fixed6x12.wingsfont')
    {:ok, fontname}
  end

  def render(model) do
    GenServer.call(:oledsrv128x64, {:render, model})
  end

  def handle_call({:render, model}, _from, state = fontname) do
    imagelines = model.textdata
    |> String.to_char_list
    |> Enum.chunk(model.size.x, model.size.x, '                     ')

    egd = :egd.create(128,64)
    :egd.text(egd, {0,-4}, fontname, Enum.at(imagelines, 0), :egd.color(:black))
    :egd.text(egd, {0, 4}, fontname, Enum.at(imagelines, 1), :egd.color(:black))
    :egd.text(egd, {0,12}, fontname, Enum.at(imagelines, 2), :egd.color(:black))
    :egd.text(egd, {0,20}, fontname, Enum.at(imagelines, 3), :egd.color(:black))
    :egd.text(egd, {0,28}, fontname, Enum.at(imagelines, 4), :egd.color(:black))
    :egd.text(egd, {0,36}, fontname, Enum.at(imagelines, 5), :egd.color(:black))
    :egd.text(egd, {0,44}, fontname, Enum.at(imagelines, 6), :egd.color(:black))
    :egd.text(egd, {0,52}, fontname, Enum.at(imagelines, 7), :egd.color(:black))

    imagedata = :egd.render(egd, :raw_bitmap)
    |> tuple28bits
    |> Enum.map(&(Bitwise.bxor(255, &1)))
    |> :binary.list_to_bin

    :egd.destroy(egd)

    {:reply, imagedata, state}
  end

  def tuple28bits(<<
                      a :: size(1), _ :: size(23),
                      b :: size(1), _ :: size(23),
                      c :: size(1), _ :: size(23),
                      d :: size(1), _ :: size(23),
                      e :: size(1), _ :: size(23),
                      f :: size(1), _ :: size(23),
                      g :: size(1), _ :: size(23),
                      h :: size(1), _ :: size(23),
                                    rest :: binary>>) do
     << returnme :: size(8) >> =
       <<
        h :: size(1),
        g :: size(1),
        f :: size(1),
        e :: size(1),
        d :: size(1),
        c :: size(1),
        b :: size(1),
        a :: size(1) >>

    [ returnme | tuple28bits(rest) ]


  end
  def tuple28bits(<<>>), do: []





end
