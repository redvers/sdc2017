require Logger
defmodule SDC2017.Tbox do
  defstruct cursor: %{x: 0, y: 0}, size: %{x: 21, y: 8},
    textdata: "                                                                                                                                                                        "

  def cls do
    %SDC2017.Tbox{}
  end

  def pp(model) do
    model.textdata
    |> String.to_char_list
    |> Enum.chunk(model.size.x, model.size.x, '                     ')
    |> Enum.map(&(List.to_string(&1) |> inspect))
    |> Enum.map(&(IO.puts(&1)))

    model
  end

  def crlf(model) do
    crlf(model, 0)
  end
  def crlf(model = %SDC2017.Tbox{cursor: %{x: x, y: y}}, cnt) do
    Map.put(model, :cursor, %{x: cnt, y: (y+1)})
  end

  def print(model, cursor, text) do
    Map.put(model, :cursor, cursor)
    |> print(text)
  end

  def print(model, text) do
    textlen = String.length(text)
    index   = cursor2index(model)

    part1   = String.slice(model.textdata, 0, index)
    replme  = String.slice(model.textdata, index, textlen)
    part2   = String.slice(model.textdata, (index + textlen), 168)
    result  =
      part1 <> text <> part2
      |> String.to_char_list
      |> Enum.chunk(model.size.x, model.size.x, '                     ')
      |> Enum.reverse
      |> Enum.take(model.size.y)
      |> Enum.reverse
      |> List.flatten
      |> List.to_string

    Map.put(model, :textdata, result)
    |> Map.put(:cursor, index2cursor(index + textlen))

  end

  def cursor2index(model) do
    model.cursor.x + (model.cursor.y * 21)
  end
  def index2cursor(index) when index > 167 do
    index2cursor(index - 21)
  end
  def index2cursor(index) do
    %{x: rem(index, 21), y: div(index, 21)}
  end


end
