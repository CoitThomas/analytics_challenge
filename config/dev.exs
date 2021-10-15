import Config

config :analytics_challenge, AnalyticsChallenge.Repo,
  database: "postgres_dev_1",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 30,
  timeout: 120_000
