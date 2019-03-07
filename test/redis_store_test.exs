defmodule ElixirLeaderboard.RedisStoreTest do
  use ExUnit.CaseTemplate
  alias ElixirLeaderboard.{Leaderboard, RedisStore}

  setup do
    board = Leaderboard.create!(name: :test1, store: RedisStore, indexer: %{})
    Leaderboard.clear(board)
    {:ok, board: board}
  end
end
