defmodule AnalyticsChallenge.Repo.Migrations.AddPagecountsTable do
  use Ecto.Migration

  def change do
    create table("pagecounts") do
      add :language_code, :string, size: 3
      add :page_name, :string
      add :view_count, :integer
      add :year, :integer
      add :month, :integer
      add :day, :integer
    end
  end
end
