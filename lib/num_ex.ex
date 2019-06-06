defmodule NumEx do
  @moduledoc """
  Documentation for Numex.
  """

  defstruct l: [], shape: nil
  @type t :: %NumEx{l: list}

  defimpl Inspect do
    import Inspect.Algebra
    def inspect(%NumEx{l: arr}, ops) do
      concat(["array(", to_doc(arr, ops), ")"])
    end
  end

  def array(list) do
    %NumEx{l: list}
  end

  import Kernel, except: [+: 2, -: 2, /: 2, *: 2]
  # override operations do import to make it available
  @spec left + NumEx.t :: NumEx.t when left: NumEx.t
  def left + right when is_map(left) do
    array(add(left.l, right.l))
  end

  @spec integer + integer :: integer
  @spec float + float :: float
  @spec integer + float :: float
  @spec float + integer :: float
  def left + right do
    :erlang.+(left, right)
  end

  @spec left - NumEx.t :: NumEx.t when left: NumEx.t
  def left - right when is_map(left) or is_map(right) do
    array(_sub(left, right))
  end

  @spec integer - integer :: integer
  @spec float - float :: float
  @spec integer - float :: float
  @spec float - integer :: float
  def left - right do
    :erlang.-(left, right)
  end

  @spec left * NumEx.t :: NumEx.t when left: NumEx.t
  def left * right when is_map(left) do
    array(_mult(left, right))
  end

  @spec integer * integer :: integer
  @spec float * float :: float
  @spec integer * float :: float
  @spec float * integer :: float
  def left * right do
    :erlang.*(left, right)
  end

  @spec left / NumEx.t :: float when left: NumEx.t
  def left / right when is_map(left) do
    array(div_list(left.l, right))
  end

  @spec number / number :: float
  def left / right do
    :erlang./(left, right)
  end

  defimpl Enumerable, for: NumEx do
    def count(%NumEx{l: arr}) do
      { :ok, length(arr)}
    end
    def member?(%NumEx{l: arr}, val) when is_list(hd arr) do
      res =
       arr
        |> Flow.from_enumerable
        |> Flow.map(fn x -> Enum.any?(x, fn x -> x == val end) end)
        |> Enum.any?
      { :ok, res }
    end
    def member?(%NumEx{l: arr}, val) do
      { :ok, Enum.any?(arr, fn x -> x == val end) }
    end
    def reduce(%NumEx{l: arr}, acc, func) when is_list(hd arr) do
      func_wrap = fn x, {state, a} -> if state == :cont, do: func.(x, a), else: {:cont, [x]++a} end
      res =
        arr
        |> Enum.reverse
        |> Enum.map(
          fn vec -> 
            vec = Enum.reverse(vec)
            {_, res} = :lists.foldl(func_wrap, acc, vec)
            res 
          end)
        {:cont, res}
      end
    def reduce(%NumEx{l: arr}, acc, func) when is_list(arr) do
      func_wrap = fn x, {state, a} -> if state == :cont, do: func.(x, a), else: {:cont, [x]++a} end
      :lists.foldl(func_wrap, acc, arr)
    end
    
    def slice(%NumEx{l: arr}) do
      {:ok, length(arr), &Enumerable.List.slice(arr, &1, &2)}
    end
  end

  @doc """
  Addition of two lists

  ## Examples

      iex> NumEx.add([1.0, 2.0], [3.0, 4.0])
      [4.0, 6.0]

  """
  def add(list, b) when is_list(hd list) do
    list 
    |> Enum.map(&(add(&1, b)))
  end
  def add(list_a, list_b) when is_list(list_a) and is_list(list_b) do
    Enum.zip(list_a, list_b)
    |> Enum.map(fn {a, b} -> Enum.zip(a, b)
                             |> Enum.map(fn {x, y} -> x + y end)
       end)
  end
  def add(list, b) do
    Enum.zip(list, b)
    |> Enum.map(fn ({x, y}) -> x + y end)
  end

  defp _mult(nearray1, nearray2) when is_map(nearray1) do
    mult(nearray1.l, nearray2.l)
  end

  @doc """
  Multiplication for arrays

  ## Examples

      iex> NumEx.mult([[1, 2], [3, 4]], [[5, 6], [7, 8]])
      [[5, 12], [21, 32]]
      iex> NumEx.mult([[1, 2], [3, 4]], [5, 6])
      [[5, 12], [15, 24]]
      iex> NumEx.mult([1, 2], 10)
      [10, 20]

  """
  def mult(listA, listB) when is_list(hd listA) and is_list(hd listB) do
    res =
    Enum.zip(listA, listB)
    |> Enum.map(fn ({a, b}) -> mult(a, b) end)
    res
  end
  def mult(list, b) when is_list(hd list) do
    list |> Enum.map(&(mult(&1, b)))
  end
  def mult(list, b) when is_list b do
    Enum.zip(list, b) |> Enum.map(fn ({x, y}) -> x * y end)
  end
  def mult(list, b) do
    list |> Enum.map(&(&1 * b))
  end

  @doc """
  Transpose

  ## Examples

      iex> NumEx.transpose([[1, 2], [3, 4]])
      [[1, 3], [2, 4]]
      iex> NumEx.transpose([1, 2])
      [[1], [2]]
      iex> NumEx.transpose([[1], [2]])
      [[1, 2]]

  """
  def transpose(nearray) when is_map(nearray) do
    array(transpose(nearray.l))
  end
  def transpose(list) when is_list(hd list) do
    arr = List.duplicate([], length(hd list))
    list |> Enum.reduce(arr, fn (xx, arr) -> _transpose(xx, arr) end)
    |> Enum.map(fn (x) -> Enum.reverse(x) end)
  end
  def transpose(list) do
    _transpose(list, List.duplicate([], length(list)))
  end
  defp _transpose(list, arr) do
    list
    |> Enum.reduce(arr, fn (x, arr) -> (tl arr)++[[x]++(hd arr)] end)
  end

  @doc """
  Division for arrays

  ## Examples

      iex> NumEx.div_list([[2, 4], [6, 8]], 2)
      [[1.0, 2.0], [3.0, 4.0]]
      iex> NumEx.div_list([1.0, 2.0], 2)
      [0.5, 1.0]

  """
  def div_list(list, denom) when is_list(hd list) do
    list 
    |> Enum.map(&(div_list(&1, denom)))
  end
  def div_list(list, denom) do
    list 
    |> Enum.map(fn(x) -> x / denom end)
  end

  defp _sub(nearray1, nearray2) when is_map(nearray1) and is_map(nearray2) do
    sub(nearray1.l, nearray2.l)
  end
  defp _sub(nearray1, listB) when is_map(nearray1) do
    sub(nearray1.l, listB)
  end
  defp _sub(listA, nearray) when is_map(nearray) do
    sub(listA, nearray.l)
  end
  def sub(listA, listB) when is_list(hd listA) and is_list(hd listB) do
    Enum.zip(listA, listB)
    |> Enum.map(fn ({as, bs}) -> sub(as, bs) end)
  end
  def sub(list, b) when is_list(hd list) do
    list |> Enum.map(&sub(&1, b))
  end
  def sub(a, list) when is_list(hd list) do
    list |> Enum.map(&sub(a, &1))
  end
  def sub(a, b) when is_list(a) and is_list(b) do
    Enum.zip(a, b) 
    |> Enum.map(fn {x, y} -> Float.floor(x - y, 8) end)
  end
  def sub(a, b) when is_list(b) do
    b |> Enum.map(&(a - &1))
  end
  def sub(a, b) do
    a |> Enum.map(&(&1 - b))
  end

  def dot(aa, bb) when is_map(aa) do
    array(dot(aa.l, bb.l))
  end
  def dot(aa, bb) when is_list(hd aa) do
    bbt = transpose(bb)
    aa
    |> Enum.with_index
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.map(fn {list, idx} -> {_dot_row(list, bbt), idx} end)
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
  end
  def dot(a, b) do
    _dot_calc(a, b)
  end
  defp _dot_row(a, b) do
    b |> Enum.map(&(_dot_calc(a, &1)))
  end
  defp _dot_calc(a, b) do
    Enum.zip(a, b)
    |> Enum.reduce(0, fn ({a, b}, acc) -> Float.floor(acc + a * b, 8) end)
  end

  def sum(mat) do
    mat
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.map(&sum(&1, 1))
    |> Enum.sum
  end
  def sum(nearray, axis) when is_map(nearray) do
    array(sum(nearray.l, axis))
  end
  def sum(mat, 0) do
    _sum(mat, [])
  end
  defp _sum(mat, res) when length(hd mat) > 0 do
    {s, mat} =
    mat |> Enum.reduce({0, []},
           fn vec, {acc, arr} ->
            {acc + (hd vec), [(tl vec)]++arr}
           end)
    _sum(mat, [s]++res)
  end
  defp _sum(_mat, sums) do 
    Enum.reverse sums
  end
 
  def sum(mat, 1) when is_list(hd mat) do
    mat 
    |> Enum.map(&(Enum.sum(&1)))
  end
  def sum(vec, 1) do
    vec |> Enum.sum
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
  def zeros_like(list) when is_list(hd list) do
    Enum.reverse(list)
    |> Enum.reduce([], fn row, arr -> [zeros_like(row)] ++ arr end)
  end
  def zeros_like(list) do
    List.duplicate([0.0], length(list))
  end

  def zeros(n, :int) do
    List.duplicate(0, n)
  end
  def zeros(n, :float) do
    List.duplicate(0.0, n)
  end
  def zeros(n, dim, :int) do
    List.duplicate(List.duplicate(0, n), dim)
  end
  def zeros(n, dim, :float) do
    List.duplicate(List.duplicate(0.0, n), dim)
  end

  def one_hot(n, t) do
    0..n-1
    |> Enum.map(&(if &1 != t, do: 0, else: 1))
  end

  def argmax(list) when is_list(hd list) do
    Enum.map(list, &(argmax(&1)))
  end
  def argmax(list) do
    elem(list |> Enum.with_index 
              |> Enum.max_by(&(elem(&1, 0))), 1)
  end

  def softmax(nearray) when is_map(nearray) do
    array(softmax(nearray.l))
  end
  def softmax(x) when is_list (hd x) do
    x |> Enum.map(&(softmax(&1)))
  end
  def softmax(x) do
    x = sub(x, Enum.max(x)) |> Enum.map(&(:math.exp(&1))) # do sub to avoid overflow
    div_list(x, Enum.sum(x))
  end

  def avg(list) do
    Enum.sum(list) / length(list)
  end

  def sqrt(x) when is_list(hd x) do
    x |> Enum.map(&sqrt(&1))
  end
  def sqrt(x) when is_list(x) do
    x |> Enum.map(&:math.sqrt(&1))
  end
  def sqrt(x) do
    :math.sqrt(x)
  end

  def pow(x, n) when is_list(hd x) do
    x |> Enum.map(&pow(&1, n))
  end
  def pow(x, n) when is_list(x) do
    x |> Enum.map(&:math.pow(&1, n))
  end
  def pow(x, n) do
    :math.pow(x, n)
  end
end