defmodule AnalyticsChallenge.Repo.Migrations.AddPagecountsTable do
  use Ecto.Migration

  def change do
    create table(:pagecounts) do
      add :language_code, :string
      add :page_name, :text
      add :view_count, :integer
      add :year, :integer
      add :month, :integer
      add :day, :integer
      add :hour, :integer
    end

    create unique_index(:pagecounts, [:language_code, :page_name], name: :wiki_page)
  end
end
