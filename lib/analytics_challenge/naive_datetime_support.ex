defmodule AnalyticsChallenge.NaiveDatetimeSupport do
  @moduledoc """
  Helper functions for dealing with NaiveDatetimes.
  """

  @doc """
  Parses a NaiveDatetime into a tuple of strings with the following form: {YYYY, MM, DD, HH}
  The month, day, and year are padded to include a leading 0 if it is a single digit.
  """
  @spec parse_to_strings(NaiveDatetime.t()) :: {String.t(), String.t(), String.t(), String.t()}
  def parse_to_strings(naive_datetime) do
    year = Integer.to_string(naive_datetime.year)
    month = to_padded_str(naive_datetime.month)
    day = to_padded_str(naive_datetime.day)
    hour = to_padded_str(naive_datetime.hour)

    {year, month, day, hour}
  end

  defp to_padded_str(integer) do
    integer
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
