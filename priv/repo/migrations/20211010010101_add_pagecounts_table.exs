defmodule AnalyticsChallenge.Repo.Migrations.AddPagecountsTable do
  use Ecto.Migration

  def change do
    create table(:pagecounts) do
      add :language_code, :string
      add :page_name, :text
      add :view_count, :integer
      add :when_viewed, :naive_datetime
    end

    create unique_index(
      :pagecounts,
      [:language_code, :page_name, :when_viewed],
      name: :wiki_page_hourly_views
    )
  end
end
