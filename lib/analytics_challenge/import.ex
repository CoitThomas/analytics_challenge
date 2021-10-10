defmodule AnalyticsChallenge.Import do
  @moduledoc """
  Responsible for fetching the pagecount data set from wikipedia.
  """
  @base_url Application.compile_env(:analytics_challenge, :pagecounts_base_url)

  @doc """
  Utilizes an HTTP client to access the pagecount data from the web and bring it into memory.
  """
  @spec by_hour(String.t(), String.t(), String.t(), String.t()) :: list(String.t())
  def by_hour(year, month, day, hour) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(build_url(year, month, day, hour))
    decompress(body)
  end

  defp build_url(year, month, day, hour) do
    "#{@base_url}/#{year}/#{year}-#{month}/pagecounts-#{year}#{month}#{day}-#{hour}0000.gz"
  end

  defp decompress(zipped_data) do
    zipped_data
    |> :zlib.gunzip()
    |> String.split("\n", trim: true)
  end
end
