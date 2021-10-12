defmodule AnalyticsChallenge.Pagecount do
  @moduledoc """
  This module defines the schema and changeset function for operating on the pagecounts table with Ecto.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "pagecounts" do
    field(:language_code, :string)
    field(:page_name, :string)
    field(:view_count, :integer)
    field(:when_viewed, :naive_datetime)
  end

  def changeset(pagecount, attrs) do
    pagecount
    |> cast(attrs, [:language_code, :page_name, :view_count, :when_viewed])
    |> validate_required([:language_code, :page_name, :view_count, :when_viewed])
    |> unique_constraint(:no_dup_wiki_page_hourly_views, name: :wiki_page_hourly_views)
    # The smallest language code type is ISO 639-1 which has a length of 2
    |> validate_length(:language_code, min: 2)
    |> validate_length(:page_name, min: 1)
    |> validate_number(:view_count, greater_than: 0)
  end
end
