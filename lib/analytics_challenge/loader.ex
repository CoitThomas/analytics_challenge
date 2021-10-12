defmodule AnalyticsChallenge.Loader do
  @moduledoc """
  GenServer process that acts as a data importation driver program for the application.

  When given a NaiveDatetime, the worker will load the historical Wikipedia pagecounts data set for
  that particular date and hour into the database.

  NOTE: Although it is possible to fetch the pagecount data for an arbitrary date and hour, it is
  only possible to fetch a data set for an arbitrary date and hour within the following fixed range:

  ~N[2007-12-09 18:00:00] - ~N[2016-08-05 12:00:00].

  Additionally, it should be understood that 'hour' is the smallest level of granularity. Including
  anything other than zeros for the minutes and seconds of the NaiveDatetime will not yield any
  results.
  """
  use GenServer

  alias AnalyticsChallenge.Import
  alias AnalyticsChallenge.Persist

  @spec start_link(list) :: GenServer.on_start()
  def start_link(_) do
    config = Application.get_env(:analytics_challenge, :loader)
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @spec load_pagecounts_for_hour(NaiveDatetime.t()) :: atom
  def load_pagecounts_for_hour(date_and_hour) do
    GenServer.call(__MODULE__, {:load_pagecounts_for_hour, date_and_hour})
  end

  # Callbacks
  @spec init(map) :: {:ok, map}
  def init(config) do
    {:ok, config}
  end

  @spec handle_call({atom, NaiveDatetime.t()}, GenServer.from(), list) :: {:reply, atom, list}
  def handle_call({:load_pagecounts_for_hour, date_and_hour}, _from, config) do
    response =
      config[:base_url]
      |> AnalyticsChallenge.Import.raw_pagecounts(date_and_hour)
      |> AnalyticsChallenge.Persist.to_postgres(date_and_hour, config[:batch_size])

    {:reply, response, config}
  end
end
