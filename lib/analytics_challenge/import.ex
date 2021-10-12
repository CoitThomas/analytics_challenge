defmodule AnalyticsChallenge.Import do
  @moduledoc """
  Responsible for fetching the pagecount data set from wikipedia.
  """

  @doc """
  Utilizes an HTTP client to access the pagecount data from the web and bring it into memory.
  """
  @spec by_date_and_hour(String.t(), tuple) :: list(String.t())
  def by_date_and_hour(base_url, date_and_hour) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(build_url(base_url, date_and_hour))
    decompress(body)
  end

  defp build_url(base_url, {year, month, day, hour} = _date_and_hour) do
    "#{base_url}/#{year}/#{year}-#{month}/pagecounts-#{year}#{month}#{day}-#{hour}0000.gz"
  end

  defp decompress(zipped_data) do
    zipped_data
    |> :zlib.gunzip()
    |> String.split("\n", trim: true)
  end
end
