defmodule AnalyticsChallenge.Pagecount do
  @moduledoc """
  This module defines the schema and changeset function for operating on the pagecounts table with Ecto
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "pagecounts" do
    field(:language_code, :string)
    field(:page_name, :string)
    field(:view_count, :integer)
    field(:year, :integer)
    field(:month, :integer)
    field(:day, :integer)
    field(:hour, :integer)
  end

  def changeset(pagecount, attrs) do
    pagecount
    |> cast(attrs, [:language_code, :page_name, :view_count, :year, :month, :day])
    |> validate_required([:language_code, :page_name, :view_count])
    |> unique_constraint(:no_dup_wiki_pages, name: :wiki_page)
    # The smallest language code type is ISO 639-1 which has a length of 2
    |> validate_length(:language_code, min: 2)
    |> validate_number(:view_count, greater_than: 0)
    # The Wiki pagecount files are only for the years 2007-2016
    |> validate_inclusion(:year, 2007..2016)
    |> validate_inclusion(:month, 1..12)
    |> validate_inclusion(:day, 1..31)
    |> validate_inclusion(:hour, 0..23)
  end
end
