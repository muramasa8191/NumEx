defmodule NumEx do
  @moduledoc """
  Documentation for Numex.
  """

  @doc """
  Addition of two lists

  ## Examples

      iex> NumEx.add([1.0, 2.0], [3.0, 4.0])
      [4.0, 6.0]

  """
  def add(a, b) do
    Enum.zip(a, b)
    |> Enum.map(fn ({a, b}) -> a + b end)
  end
  def add_mul(aa, b) do
    aa |> Enum.map(&(add(&1, b)))
  end

  def transpose(list) do
    arr = []
    arr = Stream.iterate([], &(&1++arr)) |> Enum.take(length(hd list))
    list |> Enum.reduce(arr, fn (xx, arr) -> _transpose(xx, arr) end)
    |> Enum.map(fn (x) -> Enum.reverse(x) end)
  end
  defp _transpose(list, arr) do
    list
    |> Enum.reduce(arr, fn (x, arr) -> (tl arr)++[[x]++(hd arr)] end)
  end

  def dot(aa, bb) do
    bbt = transpose(bb)
    aa |> Enum.map(&(_dot_row(&1, bbt)))
  end
  defp _dot_row(a, b) do
    b |> Enum.map(&(_dot_calc(a, &1)))
  end
  defp _dot_calc(a, b) do
    Enum.zip(a, b)
    |> Enum.reduce(0, fn ({a, b}, acc) -> Float.floor(acc + a * b, 8) end)
  end
end
