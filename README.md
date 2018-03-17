# CxLeaderboard

A featureful, efficient leaderboard based on ets store. Supports records of any shape.

### Features

* Ranks and percentiles
* Concurrent reads, sequential writes
* Stream API access to top entries
* O(1) querying of any entry by id
* Dynamic subset leaderboards
* Atomic rebuilds in O(2n log n) time
* Multi-node control

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cx_leaderboard` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cx_leaderboard, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cx_leaderboard](https://hexdocs.pm/cx_leaderboard).
