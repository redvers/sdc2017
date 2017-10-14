## SDC2016.Badge.XPM.readfile("/tmp/foo/foo_0006.png.xpm")
defmodule SDC2017.XPM do
  def playvid(dir) do
#    {:ok, port} = {:ok, port} = :gen_udp.open(9099, [broadcast: true])
    filelist = File.ls!(dir)
    |> Enum.filter(&(Regex.match?(~r/xpm$/, &1)))
    |> Enum.sort


    Stream.map(filelist, fn(x) -> dir <> "/" <> x end)
    |> Stream.map(&readfile/1)
    |> Stream.map(&:binary.list_to_bin/1)
    |> Stream.map(&(send30fps(&1)))
    |> Stream.run

#    :gen_udp.close(port)
  end

  def send30fps(port, binary) do
    :gen_udp.send(port, {192,168,1,255}, 2390, binary)
    Process.sleep(30)
  end



  def readfile(filename) do
    {:ok, {:erl_image,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
    [{:erl_pixmap,_,_,_,_,_,_,_,imgdata}],
      }} = :erl_img.load(String.to_char_list(filename))
      #    [{:erl_pixmap, 0, 0, 120, 47, ['white', 'black'], :palette8, [], [{46, <<1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, ...>>}, {45, <<1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, ...>>}, {44, <<1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, ...>>}, {43, <<1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 2, 1, 2, 1, 1, ...>>}, {42, <<1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 2, 2, 2, 2, ...>>}, {41, <<1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 2, 2, ...>>}, {40, <<1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, ...>>}, {39, <<1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, ...>>}, {38, <<1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, ...>>}, {37, <<1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, ...>>}, {36, <<1, 2, 1, 1, 1, 1, 2, 2, 2, 2, 1, ...>>}, {35, <<1, 2, 1, 2, 2, 2, 1, 2, 2, 2, ...>>}, {34, <<1, 2, 2, 2, 2, 2, 2, 2, 2, ...>>}, {33, <<1, 1, 1, 1, 1, 1, 1, 1, ...>>}, {32, <<1, 1, 1, 1, 1, 1, 1, ...>>}, {31, <<1, 1, 1, 1, 1, 1, ...>>}, {30, <<1, 1, 1, 1, 1, ...>>}, {29, <<1, 1, 1, 1, ...>>}, {28, <<1, 1, 1, ...>>}, {27, <<1, 1, ...>>}, {26, <<1, ...>>}, {25, ...}, {...}, ...]}]}}

    imgdata
    |> Enum.map(&binaryline/1)
    |> Enum.reduce(<<>>, fn(x,acc) -> x <> acc end)
    |> tuple8bits
  end

  def binaryline({_, data}) do
    data
  end

  def tuple8bits(
                  << a :: size(7), _ :: size(1),
                     b :: size(7), _ :: size(1),
                     c :: size(7), _ :: size(1),
                     d :: size(7), _ :: size(1),
                     e :: size(7), _ :: size(1),
                     f :: size(7), _ :: size(1),
                     g :: size(7), _ :: size(1),
                     h :: size(7), _ :: size(1),
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
        a :: size(1)  >>
    [ returnme | tuple8bits(rest) ]
  end

  def tuple8bits(<<>>), do: []

  def send30fps(img) do
    IO.inspect(img)
    GenServer.cast(:"0000173298", {:display, img})
  end


end
