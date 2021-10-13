defmodule AnalyticsChallenge.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AnalyticsChallenge.Repo,
      AnalyticsChallenge.Loader,
      AnalyticsChallenge.Writer
    ]

    opts = [strategy: :one_for_one, name: AnalyticsChallenge.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
