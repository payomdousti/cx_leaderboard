defmodule ElixirLeaderboard.MixProject do
  use Mix.Project

  def project do
    [
      description: "Fast, customizable leaderboards database.",
      app: :elixir_leaderboard,
      version: "0.1.5",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      source_url: "https://github.com/payomdousti/elixir_leaderboard",
      dialyzer: [flags: ["-Wunmatched_returns", :error_handling, :underspecs]],
      docs: [main: "README", extras: ["README.md"]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ElixirLeaderboard.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp package do
    %{
      licenses: ["Apache 2"],
      maintainers: ["Payom Dousti"],
      links: %{"GitHub" => "https://github.com/payomdousti/elixir_leaderboard"},
      files:
        ~w(lib .formatter.exs CODE_OF_CONDUCT.md LICENSE mix.exs README.md)
    }
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:benchee, "~> 0.12", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:redix, ">= 0.0.0"}
    ]
  end
end
