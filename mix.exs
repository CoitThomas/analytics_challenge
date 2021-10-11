defmodule AnalyticsChallenge.MixProject do
  use Mix.Project

  def project do
    [
      app: :analytics_challenge,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AnalyticsChallenge.Application, []}
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.5"},
      {:postgrex, "~> 0.15"},
      {:httpoison, "~> 1.8"},
      {:csv, "~> 2.4"}
    ]
  end
end
