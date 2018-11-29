defmodule NumEx.Random do
  def randn() do
    _rand()
  end
  def randn(col) do
    res = []
    Stream.repeatedly(fn -> [_rand()] ++ res end) |> Enum.take(col) |> List.flatten
  end
  def randn(row, col) do
    List.duplicate([], row)
    |> Enum.map(&(&1 ++ randn(col)))
  end
  defp _rand() do
    Float.floor(:rand.normal(0.0, 2.0), 8)
  end

  def normal(mean, var, row, col) do
    List.duplicate([], row) 
    |> Enum.map(&(&1++Stream.repeatedly(
      fn -> [:rand.normal(mean, var)] end) 
        |> Enum.take(col) 
        |> List.flatten)
    )
  end
end