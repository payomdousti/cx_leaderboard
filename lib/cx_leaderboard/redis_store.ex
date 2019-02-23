defmodule CxLeaderboard.RedisStore do
  @moduledoc """
  Use this storage engine to get efficient leaderboards powered by ets. Supports
  client/server mode via `CxLeaderboard.Leaderboard.start_link/1` and
  `CxLeaderboard.Leaderboard.async_populate/2`. This is the default storage
  engine.
  """

  @behaviour CxLeaderboard.Storage

  ## Writers

  @doc false
  def create(kwargs) do
    name = Keyword.get(kwargs, :name)
    {:ok, name}
  end

  @doc false
  def clear(name) do
    case Redix.command(:redix, ["DEL", name]) do
      {:ok, _} -> {:ok, name}
      error -> error
    end
  end

  @doc false
  def populate(name, data, indexer \\ %{}) do
    entries = Enum.flat_map(data, fn {{score, id}, payload} -> [score, id] end)

    case Redix.command(:redix, ["ZADD", name | entries]) do
      {:ok, _} -> {:ok, name}
      error -> error
    end
  end

  @doc false
  def async_populate(name, data, indexer \\ %{}) do
    commands =
      Enum.map(data, fn {{score, id}, payload} -> ["ZADD", name, score, id] end)

    case Redix.pipeline(:redix, commands) do
      {:ok, _} -> {:ok, name}
      error -> error
    end
  end

  @doc false
  def add(name, entry, indexer \\ %{}) do
    add_or_update(name, entry, indexer)
  end

  @doc false
  def remove(name, id, indexer \\ %{}) do
    case Redix.command(:redix, ["ZREM", name, id]) do
      {:ok, _} -> {:ok, name}
      error -> error
    end
  end

  @doc false
  def update(name, entry, indexer \\ %{}) do
    add_or_update(name, entry, indexer)
  end

  @doc false
  def add_or_update(name, entry, indexer \\ %{}) do
    {{score, id}, payload} = entry

    case Redix.command(:redix, ["ZADD", name, score, id]) do
      {:ok, _} -> {:ok, name}
      error -> error
    end
  end

  ## Readers

  @doc false
  def get(name, id) do
    get(name, id, 0)
  end

  @doc false
  def get(name, id, range) do
    {:ok, rank} = Redix.command(:redix, ["ZRANK", name, id])

    if rank != nil do
      {:ok, entries} =
        Redix.command(:redix, [
          "ZRANGE",
          name,
          rank,
          rank + range,
          "WITHSCORES"
        ])

      entries
      |> map_entries_to_records()
    end
  end

  @doc false
  def top(name) do
    Stream.resource(
      fn -> {0, 10} end,
      fn {start_idx, end_idx} ->
        {:ok, entries} =
          Redix.command(:redix, [
            "ZRANGE",
            name,
            start_idx,
            end_idx,
            "WITHSCORES"
          ])

        if status == :ok && !Enum.empty?(data) do
          {entries, {start_idx + end_idx + 1, end_idx + end_idx + 1}}
        else
          {:halt, {start_idx, end_idx}}
        end
      end,
      fn {start_idx, end_idx} ->
        end_idx
      end
    )
  end

  @doc false
  def bottom(name) do
    Stream.resource(
      fn -> {0, 10} end,

      fn {start_idx, end_idx} ->
        { status, data }= Redix.command(:redix, ["ZREVRANGE", name, start_idx, end_idx])
        if status == :ok && !Enum.empty?(data) do
          {data, {start_idx + end_idx + 1, end_idx + end_idx + 1}}
        else
          {:halt, {start_idx, end_idx}}
        end
      end,

      fn {start_idx, end_idx} ->
        end_idx
      end
    )
  end

  @doc false
  def count(name) do
    case Redix.command(:redix, ["ZCOUNT", name, "-inf", "+inf"]) do
      {:ok, count} -> count
      error -> error
    end
  end

  #  @doc false
  #  def start_link(lb = %{state: name}) do
  #    GenServer.start_link(Writer, {name, lb}, name: name)
  #  end
  defp map_entries_to_records(entries, index \\ 0) do
    entries
    |> Enum.chunk_every(2)
    |> Enum.with_index(index)
    |> Enum.map(fn {[entry_id, entry_score], index} ->
      {entry_score, String.to_atom(entry_id), {index, {index, nil}}}
    end)
  end

  #  @doc false
  #  def get_lb(name) do
  #    GenServer.call(name, :get_lb)
  #  end



#  defp collect_errors({nodes, bad_nodes}) do
#    errors =
#      nodes
#      |> Enum.filter(&reply_has_errors?/1)
#      |> Enum.map(fn {node, {:error, reason}} -> {node, reason} end)
#
#    Enum.reduce(bad_nodes, errors, fn bad_node, errors ->
#      [{bad_node, :bad_node} | errors]
#    end)
#  end
#
#  defp reply_has_errors?({_, {:error, _}}), do: true
#  defp reply_has_errors?(_), do: false
end
