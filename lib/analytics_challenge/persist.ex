defmodule AnalyticsChallenge.Persist do
  @moduledoc """
  X
  """
  alias AnalyticsChallenge.Pagecount
  alias AnalyticsChallenge.Repo

  @doc """
  X
  """
  @spec to_postgres(list(map)) :: :ok
  def to_postgres(pagecount_maps) do
    pagecount_maps
    |> Enum.chunk_every(1000)
    |> Enum.each(fn batch -> Repo.insert_all(Pagecount, batch) end)
  end

  @doc """
  TODO: add hour tuple parameter for 'any arbitrary hour'
  """
  @spec prep_raw_pagecounts(list(String.t())) :: list(map)
  def prep_raw_pagecounts(raw_pagecounts) do
    raw_pagecounts
    |> Enum.map(fn raw_pagecount -> String.split(raw_pagecount, " ") end)
    |> Enum.filter(&valid_raw_pagecount?/1)
    |> Enum.map(&convert_to_map/1)
  end

  defp valid_raw_pagecount?([language_code, page_name, _, _]) do
    !String.contains?(language_code, ".") && !String.contains?(page_name, ":")
  end

  # TODO: add hour tuple parameter for 'any arbitrary hour'
  defp convert_to_map([language_code, page_name, view_count, _]) do
    %{language_code: language_code, page_name: page_name, view_count: String.to_integer(view_count)}
  end
end