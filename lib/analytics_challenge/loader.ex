defmodule AnalyticsChallenge.Loader do
  @moduledoc """
  GenServer process that acts as a data importation driver program for the application.

  When given a NaiveDatetime, the worker will load the historical Wikipedia pagecounts data set for
  that particular date and hour into the database.

  NOTE: The range of dates and hours is fixed. It is only possible to fetch a data set for dates
  and hours within the following range: ~N[2007-12-09 18:00:00] - ~N[2016-08-05 12:00:00].
  Additionally, it should be understood that 'hour' is the smallest level of granularity. Including
  anything other than zeros for the minutes and seconds of the NaiveDatetime will not yield any
  results.
  """
  use GenServer

  alias AnalyticsChallenge.Import
  alias AnalyticsChallenge.Persist

  @spec start_link(list) :: GenServer.on_start()
  def start_link(_) do
    state = Application.get_env(:analytics_challenge, :loader)
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @spec init(map) :: {:ok, map}
  def init(state) do
    {:ok, state}
  end
end
