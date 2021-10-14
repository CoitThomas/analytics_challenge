defmodule AnalyticsChallenge.QueryTest do
  use AnalyticsChallenge.RepoCase

  alias AnalyticsChallenge.Pagecount
  alias AnalyticsChallenge.Query

  def pagecount_map(language_code, page_name, view_count, when_viewed) do
    %{
      language_code: language_code,
      page_name: page_name,
      view_count: view_count,
      when_viewed: when_viewed
    }
  end

  test "correct number of rows counted" do
    Repo.insert_all(
      Pagecount,
      [pagecount_map("en", "USS_Alexander_Hamilton_(SSBN-617)", 1, ~N[2014-11-27 15:00:00])]
    )

    assert 1 == Query.row_count()
  end

  test "no duplicate language codes" do
    Repo.insert_all(
      Pagecount,
      [
        pagecount_map("en", "Royal_New_Zealand_Air_Force", 13, ~N[2014-11-27 15:00:00]),
        pagecount_map("en", "Sistine_Chapel_ceiling", 26, ~N[2014-11-27 15:00:00]),
        pagecount_map("en", "Chupacabra_vs._The_Alamo", 1, ~N[2014-11-27 15:00:00]),
        pagecount_map(
          "it",
          "Episodi_di_Fairy_Tail_(quarta_stagione)",
          14,
          ~N[2014-11-27 15:00:00]
        ),
        pagecount_map("ko", "%ED%95%99%EC%82%AC", 4, ~N[2014-11-27 15:00:00]),
        pagecount_map("ko", "%ED%95%98%ED%9B%84%EB%8F%88", 3, ~N[2014-11-27 15:00:00])
      ]
    )

    assert ["en", "it", "ko"] == Query.unique_language_codes()
  end

  test "only top ten are returned for the given language code and datetime" do
    Repo.insert_all(
      Pagecount,
      [
        pagecount_map("es", "Subcomandante_Marcos", 14, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subconjunto", 10, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subconsciente", 3, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subconsumo", 2, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subcontinente_Indio", 1, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subcontrataci%C3%B3n", 9, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subcultura", 18, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subcultura_g%C3%B3tica", 17, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subcultura_gotica", 1, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subcut%C3%A1nea", 4, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subdelegaci%C3%B3n_del_Gobierno", 1, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subdesarrollo", 26, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subdesbordamiento_de_b%C3%BAfer", 1, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subdeterminaci%C3%B3n", 1, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subdominio", 6, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subducci%C3%B3n", 16, ~N[2014-11-27 15:00:00]),
        pagecount_map("es", "Subempleo", 13, ~N[2014-11-27 15:00:00])
      ]
    )

    expected_result = [
      ["es", "Subdesarrollo", 26],
      ["es", "Subcultura", 18],
      ["es", "Subcultura_g%C3%B3tica", 17],
      ["es", "Subducci%C3%B3n", 16],
      ["es", "Subcomandante_Marcos", 14],
      ["es", "Subempleo", 13],
      ["es", "Subconjunto", 10],
      ["es", "Subcontrataci%C3%B3n", 9],
      ["es", "Subdominio", 6],
      ["es", "Subcut%C3%A1nea", 4]
    ]

    # Confirm more than 10 exist in the db
    assert 17 == Query.row_count()

    # Confirm the 10 we expect get returned
    assert expected_result == Query.top_ten_for_language_at_hour("es", ~N[2014-11-27 15:00:00])

    # Confirm the original rows still exist
    assert 17 == Query.row_count()

    # Confirm we don't get anything back for other language codes
    assert [] == Query.top_ten_for_language_at_hour("fr", ~N[2014-11-27 15:00:00])
    assert [] == Query.top_ten_for_language_at_hour("zh", ~N[2014-11-27 15:00:00])

    # Confirm we don't get anything back for other datetimes
    assert [] == Query.top_ten_for_language_at_hour("es", ~N[2015-05-12 17:00:00])
    assert [] == Query.top_ten_for_language_at_hour("es", ~N[2010-05-13 16:00:00])
  end
end
