defmodule RedisStoreTest do
  use CxLeaderboard.RedisStorageCase
  alias CxLeaderboard.{Leaderboard, RedisStore}

  setup do
    board = Leaderboard.create!(name: :test1, store: RedisStore, indexer: %{})
    Leaderboard.clear(board)
    {:ok, board: board}
  end

#  setup_with_mocks([
#    {Redix, [],
#     [
#       command: fn
#         _, ["ZADD", _, _, _] -> {:ok, 1}
#         _, ["ZRANK", _, _, _, _] -> {:ok, 1}
#         _, ["ZRANK", _, _, _, _] -> {:ok, 1}
#         _, ["ZCARD", _] -> {:ok, 1}
#       end
#     ]}
#  ]) do
#    :ok
#  end
#
#  test "test that this is working" do
#    assert Redix.command(:redix, ["ZADD", :lb, 10, :id1]) == {:ok, 1}
#  end
end
