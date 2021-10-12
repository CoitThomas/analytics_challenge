defmodule AnalyticsChallenge.Persist do
  @moduledoc """
  X
  """
  alias AnalyticsChallenge.Pagecount
  alias AnalyticsChallenge.Repo

  @doc """
  X
  """
  @spec to_postgres(list(map), NaiveDatetime.t(), pos_integer) :: :ok
  def to_postgres(raw_pagecounts, when_viewed, batch_size) do
    raw_pagecounts
    |> prep_raw_pagecounts(when_viewed)
    |> Enum.chunk_every(batch_size)
    |> Enum.each(fn batch -> Repo.insert_all(Pagecount, batch) end)
  end

  defp prep_raw_pagecounts(raw_pagecounts, when_viewed) do
    raw_pagecounts
    |> Enum.map(fn raw_pagecount -> String.split(raw_pagecount, " ") end)
    |> Enum.filter(&valid_raw_pagecount?/1)
    |> Enum.map(&combine_into_map(&1, when_viewed))
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

  defp combine_into_map([language_code, page_name, view_count, _], when_viewed) do
    %{
      language_code: language_code,
      page_name: page_name,
      view_count: String.to_integer(view_count),
      when_viewed: when_viewed
    }
  end
end
