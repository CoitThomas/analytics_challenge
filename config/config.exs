import Config

config :analytics_challenge,
  ecto_repos: [AnalyticsChallenge.Repo],
  loader: [
    pagecounts_base_url: "https://dumps.wikimedia.org/other/pagecounts-raw",
    db_insertion_batch_size: 10000
  ]

config :analytics_challenge, AnalyticsChallenge.Repo,
  database: "analytics_challenge_postgres_1",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
