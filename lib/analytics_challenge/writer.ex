defmodule AnalyticsChallenge.Writer do
  @moduledoc """
  GenServer process that acts as a data exportation driver program for the application.

  When given a NaiveDatetime, the worker will query postgres for the pagecounts data that
  corresponds to that particular date and hour. It then writes that data out to a CSV file into a
  directory specified in the writer config.

  NOTE: Although it is possible to fetch the pagecount data for an arbitrary date and hour, it is
  only possible to fetch a data set for an arbitrary date and hour within the following fixed range:

  ~N[2007-12-09 18:00:00] - ~N[2016-08-05 12:00:00].

  Additionally, it should be understood that 'hour' is the smallest level of granularity. Including
  anything other than zeros for the minutes and seconds of the NaiveDatetime will not yield any
  results.
  """
  use GenServer

  alias AnalyticsChallenge.Persist
  alias AnalyticsChallenge.Query

  @spec start_link(list) :: GenServer.on_start()
  def start_link(_) do
    config = Application.get_env(:analytics_challenge, :writer)
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @spec top_ten_for_all_at_hour(NaiveDatetime.t()) :: atom
  def top_ten_for_all_at_hour(date_and_hour) do
    GenServer.call(__MODULE__, {:top_ten_for_all_at_hour, date_and_hour}, :infinity)
  end

  @spec top_ten_for_subset_at_hour(list(String.t()), NaiveDatetime.t()) :: atom
  def top_ten_for_subset_at_hour(language_codes, date_and_hour) do
    GenServer.call(__MODULE__, {:top_ten_for_subset_at_hour, language_codes, date_and_hour}, :infinity)
  end

  # Callbacks
  @spec init(list) :: {:ok, list}
  def init(config) do
    {:ok, config}
  end

  @spec handle_call({atom, NaiveDatetime.t()}, GenServer.from(), list) :: {:reply, atom, list}
  def handle_call({:top_ten_for_all_at_hour, date_and_hour}, _from, config) do
    description = "top_ten_for_all_language_codes"

    path =
      Persist.build_file_path(
        config[:dir_name],
        description,
        date_and_hour,
        config[:file_type]
      )

    response =
      Query.unique_language_codes()
      |> Enum.map(fn code -> Query.top_ten_for_language_at_hour(code, date_and_hour) end)
      |> Persist.to_csv(path)

    {:reply, response, config}
  end

  @spec handle_call({atom, NaiveDatetime.t()}, GenServer.from(), list) :: {:reply, atom, list}
  def handle_call({:top_ten_for_subset_at_hour, language_codes, date_and_hour}, _from, config) do
    description = "top_ten_for_language_codes_subset"

    path =
      Persist.build_file_path(
        config[:dir_name],
        description,
        date_and_hour,
        config[:file_type]
      )

    response =
      language_codes
      |> Enum.map(fn code -> Query.top_ten_for_language_at_hour(code, date_and_hour) end)
      |> Persist.to_csv(path)

    {:reply, response, config}
  end
end
