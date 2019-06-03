defmodule NumexTest do
  use ExUnit.Case
  doctest NumEx

  test "add test" do
    assert NumEx.add([1, 2], [3, 4]) == [4, 6]
  end
end
