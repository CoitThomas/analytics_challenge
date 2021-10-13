defmodule AnalyticsChallenge.RepoCase do
  @moduledoc """
  This module defines the test case to be used by Ecto tests.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      alias AnalyticsChallenge.Repo

      import Ecto
      import Ecto.Query
      import AnalyticsChallenge.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AnalyticsChallenge.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(AnalyticsChallenge.Repo, {:shared, self()})
    end

    :ok
  end
end
