defmodule AnalyticsChallenge.Import do
  @moduledoc """
  Responsible for fetching the pagecount data set from wikipedia.
  """

  @doc """
  Utilizes an HTTP client to access the pagecount historical data for a specified hour in the past.
  """
  @spec raw_pagecounts(String.t(), NaiveDatetime.t()) :: list(String.t())
  def raw_pagecounts(base_url, when_viewed) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(build_url(base_url, when_viewed))
    decompress(body)
  end

  defp build_url(base_url, when_viewed) do
    year = Integer.to_string(when_viewed.year)
    month = to_padded_string(when_viewed.month)
    day = to_padded_string(when_viewed.day)
    hour = to_padded_string(when_viewed.hour)

    "#{base_url}/#{year}/#{year}-#{month}/pagecounts-#{year}#{month}#{day}-#{hour}0000.gz"
  end

  defp decompress(zipped_data) do
    zipped_data
    |> :zlib.gunzip()
    |> String.split("\n", trim: true)
  end

  defp to_padded_string(integer) do
    integer
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
