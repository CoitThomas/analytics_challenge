defmodule AnalyticsChallenge.Persist do
  @moduledoc """
  X
  """
  alias AnalyticsChallenge.Pagecount
  alias AnalyticsChallenge.Repo

  @doc """
  X
  """
  @spec to_postgres(list(map), tuple, pos_integer) :: :ok
  def to_postgres(raw_pagecounts, date_and_hour, batch_size) do
    raw_pagecounts
    |> prep_raw_pagecounts(date_and_hour)
    |> Enum.chunk_every(batch_size)
    |> Enum.each(fn batch -> Repo.insert_all(Pagecount, batch) end)
  end

  defp prep_raw_pagecounts(raw_pagecounts, date_and_hour) do
    datetime = convert_to_datetime(date_and_hour)

    raw_pagecounts
    |> Enum.map(fn raw_pagecount -> String.split(raw_pagecount, " ") end)
    |> Enum.filter(&valid_raw_pagecount?/1)
    |> Enum.map(&combine_into_map(&1, datetime))
  end

  defp convert_to_datetime({year, month, day, hour}) do
    NaiveDateTime.from_erl!({
      {String.to_integer(year), String.to_integer(month), String.to_integer(day)},
      {String.to_integer(hour), 0, 0}
    })
  end

  defp valid_raw_pagecount?([language_code, page_name, _, _]) do
    valid_language_code?(language_code) && valid_page_name?(page_name)
  end

  defp valid_language_code?(language_code) do
    !String.contains?(language_code, ".")
  end

  defp valid_page_name?(page_name) do
    !String.contains?(page_name, ":") && String.length(String.trim(page_name)) != 0
  end

  defp combine_into_map([language_code, page_name, view_count, _], datetime) do
    %{
      language_code: language_code,
      page_name: page_name,
      view_count: String.to_integer(view_count),
      when_viewed: datetime
    }
  end
end
