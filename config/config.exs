import Config

config :analytics_challenge,
  ecto_repos: [AnalyticsChallenge.Repo],
  loader: [
    base_url: "https://dumps.wikimedia.org/other/pagecounts-raw",
    batch_size: 10000
  ],
  writer: [
    dir_name: "analytics",
    file_descr: "top_ten_pagecounts_per_language",
    file_type: "csv"
  ]

config :analytics_challenge, AnalyticsChallenge.Repo,
  database: "analytics_challenge_postgres_1",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
