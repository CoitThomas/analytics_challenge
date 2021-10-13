import Config

config :analytics_challenge,
  ecto_repos: [AnalyticsChallenge.Repo],
  loader: [
    base_url: "https://dumps.wikimedia.org/other/pagecounts-raw",
    batch_size: 10000
  ],
  writer: [
    dir_name: "analytics",
    file_type: "csv"
  ]

import_config "#{config_env()}.exs"
