defmodule AnalyticsChallenge.MixProject do
  use Mix.Project

  def project do
    [
      app: :analytics_challenge,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AnalyticsChallenge.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.5"},
      {:postgrex, "~> 0.15"},
      {:httpoison, "~> 1.8"},
      {:csv, "~> 2.4"}
    ]
  end

  defp aliases do
    [
     test: ["ecto.create", "ecto.migrate", "test"]
    ]
  end
end
