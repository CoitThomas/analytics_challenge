defmodule AnalyticsChallenge.Repo do
  use Ecto.Repo,
    otp_app: :analytics_challenge,
    adapter: Ecto.Adapters.Postgres
end
