defmodule AnalyticsChallenge.Import do
  @moduledoc """
  Responsible for fetching the pagecount data set from wikipedia.
  """
  alias AnalyticsChallenge.NaiveDatetimeSupport

  @doc """
  Utilizes an HTTP client to access the pagecount historical data for a specified hour in the past.
  """
  @spec raw_pagecounts(String.t(), NaiveDatetime.t()) :: list(String.t())
  def raw_pagecounts(base_url, when_viewed) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(build_url(base_url, when_viewed))
    decompress(body)
  end

  defp build_url(base_url, when_viewed) do
    {year, month, day, hour} = NaiveDatetimeSupport.parse_to_strings(when_viewed)
    "#{base_url}/#{year}/#{year}-#{month}/pagecounts-#{year}#{month}#{day}-#{hour}0000.gz"
  end

  defp decompress(zipped_data) do
    zipped_data
    |> :zlib.gunzip()
    |> String.split("\n", trim: true)
  end
end
