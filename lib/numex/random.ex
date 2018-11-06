defmodule NumEx.Random do
  def randn(col) do
    _randn(col, [])
  end
  defp _randn(0, list) do
    list
  end
  defp _randn(col, list) do
    _randn(col - 1, [_rand()] ++ list)
  end
  def randn(row, col) do
    _randn(row - 1, col, col, [[]])
  end
  defp _randn(0, 0, _, list) do
    list
  end
  defp _randn(row, 0, oricol, list) do
    _randn(row - 1, oricol, oricol, [[]] ++ list)
  end
  defp _randn(row, col, oricol, [h | t]) do
    _randn(row, col - 1, oricol, [[_rand()] ++ h] ++ t)
  end

  defp _rand() do
    Float.floor(:rand.uniform * :rand.uniform * 3.0, 8)
  end
end