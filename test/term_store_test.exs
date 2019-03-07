defmodule TermStoreTest do
  use ElixirLeaderboard.StorageCase
  alias ElixirLeaderboard.{Leaderboard, TermStore}

  setup do
    board = Leaderboard.create!(store: TermStore)
    {:ok, board: board}
  end
end
