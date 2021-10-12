defmodule AnalyticsChallenge.Persist do
  @moduledoc """
  Contains all the functions which pertain to data persistence in the app. So far, this just inludes
  postgres and csv files, but it could include other forms as well if desired.
  """
  alias AnalyticsChallenge.NaiveDatetimeSupport
  alias AnalyticsChallenge.Pagecount
  alias AnalyticsChallenge.Repo

  @doc """
  Takes in raw pagecounts data, filters out unwanted pagecounts, converts remaining pagecounts into
  maps which correspond to the pagecounts schema, and inserts the data in batches of a specified
  size into postgres.
  """
  @spec to_postgres(list(String.t()), NaiveDatetime.t(), pos_integer) :: :ok
  def to_postgres(raw_pagecounts, when_viewed, batch_size) do
    raw_pagecounts
    |> prep_for_postgres(when_viewed)
    |> Enum.chunk_every(batch_size)
    |> Enum.each(fn batch -> Repo.insert_all(Pagecount, batch) end)
  end

  @doc """
  Creates the parent directory of the file path if it doesn't already exist, takes in freshly
  queried data, de-nests one layer of lists, and writes the data out to a CSV file. The contents of
  the file are in the following form:

  <language_code>,<page_name>,<view_count>\n
  <...>,<...>,<...>\n
  ...
  """
  @spec to_csv(list(list(list(String.t() | pos_integer))), String.t()) :: :ok
  def to_csv(queried_pagecounts, path) do
    :ok = ensure_path(path)

    queried_pagecounts
    |> prep_for_csv()
    |> write_file(path)
  end

  @doc """
  Constructs a path to a file. The filename is based off of the description, extracted info from the provided
  NaiveDatetime, and desired file type.
  """
  @spec build_file_path(String.t(), String.t(), NaiveDatetime.t(), String.t()) :: String.t()
  def build_file_path(dir_name, file_descr, when_viewed, file_ext) do
    Path.join([dir_name, build_filename(file_descr, when_viewed, file_ext)])
  end

  defp prep_for_postgres(raw_pagecounts, when_viewed) do
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

  defp ensure_path(path) do
    path
    |> Path.dirname()
    |> File.mkdir_p!()
  end

  defp prep_for_csv(queried_pagecounts) do
    queried_pagecounts
    |> List.flatten()
    |> Enum.chunk_every(3)
  end

  defp write_file(content, path) do
    file = File.open!(path, [:write, :utf8])

    content
    |> CSV.encode()
    |> Enum.each(&IO.write(file, &1))
  end

  defp build_filename(descr, when_viewed, file_ext) do
    {year, month, day, hour} = NaiveDatetimeSupport.parse_to_strings(when_viewed)
    "#{descr}-#{year}#{month}#{day}-#{hour}0000.#{file_ext}"
  end
end
