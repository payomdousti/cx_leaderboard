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

    case Redix.start_link() do
      {:ok, _} -> {:ok, name}
      error -> error
    end
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
    commands = Enum.map(data, fn {{score, id}, payload} -> ["ZADD", name, score, id] end)
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
    name
  end

  @doc false
  def get(name, id, range) do
    name
  end

  @doc false
  def top(name) do
    Stream.resource(
      fn -> {0, 10} end,

      fn {start_idx, end_idx} ->
        { status, data }= Redix.command(:redix, ["ZRANGE", :lb, start_idx, end_idx])
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
  def bottom(name) do
    Stream.resource(
      fn -> {0, 10} end,

      fn {start_idx, end_idx} ->
        { status, data }= Redix.command(:redix, ["ZREVRANGE", :lb, start_idx, end_idx])
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
