import Config

config :analytics_challenge, AnalyticsChallenge.Repo,
  database: "postgres_dev_1",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 20,
  queue_target: 5000
