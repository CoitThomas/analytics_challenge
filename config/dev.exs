import Config

config :analytics_challenge, AnalyticsChallenge.Repo,
  database: "postgres_dev_1",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  after_connect_timeout: 30000
