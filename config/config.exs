import Config

config :analytics_challenge,
  ecto_repos: [AnalyticsChallenge.Repo],
  pagecounts_base_url: "https://dumps.wikimedia.org/other/pagecounts-raw"

config :analytics_challenge, AnalyticsChallenge.Repo,
  database: "analytics_challenge_postgres_1",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
