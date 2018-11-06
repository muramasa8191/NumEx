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
    _transpose(list, [])
  end
  defp _transpose([], res) do
    res
  end
  defp _transpose(list, res) do
    {vec, next} = _transpose_head(list, {[], []})
    _transpose(next, res ++ [vec])
  end
  defp _transpose_head([], result) do
    result
  end
  defp _transpose_head([[h | t] | tail], {res, next}) when t != [] do
    _transpose_head(tail, {res ++ [h], next ++ [t]})
  end
  defp _transpose_head([[h | _] | tail], {res, next}) do
    _transpose_head(tail, {res ++ [h], next})
  end

  def dot(aa, bb) do
    bbt = transpose(bb)
    aa |> Enum.map(&(_dot_row(&1, bbt, [])))
  end
  defp _dot_row(a, b, vec) do
    b |> Enum.map(&(_dot_calc(a, &1)))
  end
  defp _dot_calc(a, b) do
    Enum.zip(a, b)
    |> Enum.reduce(0, fn ({a, b}, acc) -> Float.floor(acc + a * b, 8) end)
  end
end
