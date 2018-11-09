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
  def add(list, b) when is_list(hd list) do
    list |> Enum.map(&(add(&1, b)))
  end
  def add(list, b) do
    Enum.zip(list, b)
    |> Enum.map(fn ({x, y}) -> x + y end)
  end

  def mult(list, b) when is_list(hd list) do
    list |> Enum.map(&(mult(&1, b)))
  end
  def mult(list, b) do
    list |> Enum.map(&(&1 * b))
  end
  def transpose(list) do
    arr = List.duplicate([], length(hd list))
    list |> Enum.reduce(arr, fn (xx, arr) -> _transpose(xx, arr) end)
    |> Enum.map(fn (x) -> Enum.reverse(x) end)
  end
  defp _transpose(list, arr) do
    list
    |> Enum.reduce(arr, fn (x, arr) -> (tl arr)++[[x]++(hd arr)] end)
  end

  def div(list, denom) when is_list(hd list) do
    list
    |> Enum.map(fn (xx) -> Enum.map(xx, fn(x) -> Float.floor(x / denom, 8) end) end)
  end
  def div(list, denom) do
    list |> Enum.map(fn(x) -> Float.floor(x / denom, 8) end)
  end

  def sub(list, b) when is_list(hd list) do
    list |> Enum.map(fn (aa) -> sub(aa, b) end)
  end
  def sub(a, b) do
    Enum.zip(a, b) |> Enum.map(fn {x, y} -> Float.floor(x - y, 8) end)
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

  def sum(mat) do
    arr = List.duplicate(0.0, length(hd mat))
    mat |> Enum.reduce(arr, fn(x, arr) -> add(arr, x) end)
  end

  def repeat(list, n) when is_list(hd list) do
    List.duplicate((hd list), n)
  end
  def repeat(list, n) do
    List.duplicate(list, n)
  end

  def zeros_like(list) when is_list(hd list) do
    list |> Enum.reduce([], fn (x, acc) 
      -> [List.duplicate(0.0, length(x))] ++ acc end)
  end
  def zeros_like(list) do
    List.duplicate([0.0], length(list))
  end

  def zeros(n, dim, :int) do
    List.duplicate(List.duplicate(0, n), dim)
  end
  def zeros(n, dim, :float) do
    List.duplicate(List.duplicate(0.0, n), dim)
  end
end
