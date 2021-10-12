defmodule AnalyticsChallenge.Loader do
  @moduledoc """
  GenServer process that acts as a data importation driver program for the application.

  When given a tuple with 4 strings representing the date and hour in the form: {YYYY, MM, DD, HH},
  the worker will load the Wikipedia pagecounts data set for that particular date and hour into the
  database.

  NOTE: The range of dates and hours is fixed. It is only possible to fetch a data set for dates
  and hours within the following range: {"2007", "12", "09", "18"} - {"2016", "08", "05", "12"}
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
