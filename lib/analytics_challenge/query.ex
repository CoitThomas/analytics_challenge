defmodule AnalyticsChallenge.Query do
  @moduledoc """
  Contains all the queries used for retrieving data from postgres.
  """

  import Ecto.Query
  alias AnalyticsChallenge.Pagecount
  alias AnalyticsChallenge.Repo

  @doc """
  Returns the number of rows that currently exist in the pagecounts table.
  """
  @spec row_count :: pos_integer
  def row_count do
    Repo.one(from(p in Pagecount, select: count(p.id)))
  end

  @doc """
  Returns all the unique language codes that exist in the pagecounts table.
  """
  @spec unique_language_codes :: list(String.t())
  def unique_language_codes do
    Repo.all(from(p in Pagecount, select: p.language_code, distinct: p.language_code))
  end

  @doc """
  Returns the top ten page name's with the most views for a given language code.
  """
  @spec top_ten_for_language_at_hour(String.t(), NaiveDateTime.t()) ::
          list(list(String.t() | pos_integer))
  def top_ten_for_language_at_hour(language_code, when_viewed) do
    Repo.all(
      from(p in Pagecount,
        select: [p.language_code, p.page_name, p.view_count],
        where: p.language_code == ^language_code,
        where: p.when_viewed == ^when_viewed,
        order_by: [desc: p.view_count],
        limit: 10
      )
    )
  end
end
