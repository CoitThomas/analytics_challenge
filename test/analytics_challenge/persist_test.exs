defmodule AnalyticsChallenge.PersistTest do
  use AnalyticsChallenge.RepoCase

  alias AnalyticsChallenge.Persist
  alias AnalyticsChallenge.Query

  @when_viewed ~N[2013-08-12 09:00:00]
  @batch_size 100

  def valid_raw_pagecounts do
    [
      "en American_game_show_winnings_records 3 72777",
      "en American_gender_stereotypes 1 131614",
      "en American_ginseng 4 81516",
      "en American_gizzard_shad 1 13211",
      "en American_golden_plover 1 15523",
      "en American_gothic 2 35710",
      "en American_government 1 49598",
      "en American_handball 3 56517",
      "en American_heritage_magazine 1 67652",
      "en American_history_x 1 25914",
      "en American_holidays 1 98892",
      "en American_humor 3 74186",
      "en American_idiot 1 66915",
      "en American_immigration_to_Mexico 1 21453",
      "en American_imperialism 16 2665052"
    ]
  end

  def invalid_raw_pagecounts do
    [
      "aa File:Sleeping_lion.jpg 1 8030",
      "aa Special:Statistics 1 20493",
      "aa Special:WhatLinksHere/File:Crystal_Clear_app_email.png 1 5412",
      "aa User:%E5%8F%B8%E5%BE%92%E4%BC%AF%E9%A2%9C 2 20096",
      "aa User:149.62.201.0/24 1 4802",
      "aa.b Special:Log/block 2 10822",
      "aa.b Special:WhatLinksHere/File:Goodbye_Frank.JPG 1 5053",
      "aa.b User:2A02:1810:3E2A:F800:51DE:CC5E:6544:DB3 1 4834",
      "aa.b User:46.47.7.41 1 4753",
      "aa.b User_talk:J.delanoy 1 4745",
      "aa.b User_talk:Sevela.p 1 5786",
      "aa.b Wikidata 1 4654",
      "aa.b Wikiquote 1 4658"
    ]
  end

  test "Verify that valid pagecounts make it into postgres" do
    # Check that the db is empty beforehand
    assert 0 == Query.row_count()

    :ok = Persist.to_postgres(valid_raw_pagecounts(), @when_viewed, @batch_size)

    assert length(valid_raw_pagecounts()) == Query.row_count()
  end

  test "Verify that invalid pagecounts do not make it into postgres" do
    # Check that the db is empty beforehand
    assert 0 == Query.row_count()

    :ok = Persist.to_postgres(invalid_raw_pagecounts(), @when_viewed, @batch_size)

    assert 0 == Query.row_count()
  end

  test "Verify that only valid pagecounts make it into postgres when combined with invalid one" do
    # Check that the db is empty beforehand
    assert 0 == Query.row_count()

    :ok =
      (invalid_raw_pagecounts() ++ valid_raw_pagecounts())
      |> Enum.shuffle()
      |> Persist.to_postgres(@when_viewed, @batch_size)

    assert length(valid_raw_pagecounts()) == Query.row_count()
  end

  test "Can construct a proper file path" do
    dir_name = "analytics"
    file_descr = "awesome_description"
    when_viewed = ~N[2011-03-25 18:00:00]
    file_ext = "csv"
    expected_path = "analytics/awesome_description-20110325-180000.csv"

    assert expected_path == Persist.build_file_path(dir_name, file_descr, when_viewed, file_ext)
  end

  @tag :tmp_dir
  test "CSV file exists and has the correct contents", %{tmp_dir: tmp_dir} do
    path = tmp_dir <> "/awesome_description-20110325-180000.csv"

    queried_pagecounts = [
      [
        ["da", "Forside", 217],
        ["da", "index.html", 100],
        ["da", "Sveriges_byer", 48],
        ["da", "John_Kerry", 31],
        ["da", "USA", 25],
        ["da", "1943", 18],
        ["da", "Danmarks_fodboldlandshold", 18],
        ["da", "Colorado", 17],
        ["da", "USA%27s_udenrigsministre", 17],
        ["da", "2004", 15]
      ],
      [
        ["fi", "index.html", 393],
        ["fi", "John_Kerry", 27],
        ["fi", "Main_Page", 24],
        ["fi", "Opus_caementicium", 22],
        ["fi", "Facebook", 22],
        ["fi", "Redi_(kauppakeskus)", 21],
        ["fi", "J%C3%A4%C3%A4kiekon_SM-liigakausi_2005%E2%80%932006", 21],
        ["fi", "Yhdysvaltain_senaatin_ulkoasiainvaliokunta", 21],
        ["fi", "Massachusetts", 20],
        ["fi", "Maksim_Bardat%C5%A1ou", 19]
      ]
    ]

    :ok = Persist.to_csv(queried_pagecounts, path)

    # Check if the file is there
    assert File.exists?(path)

    # Pull in everything from the file
    file_contents =
      path
      |> File.stream!()
      |> CSV.decode!()
      |> Enum.take(100)

    expected_contents = [
      ["da", "Forside", "217"],
      ["da", "index.html", "100"],
      ["da", "Sveriges_byer", "48"],
      ["da", "John_Kerry", "31"],
      ["da", "USA", "25"],
      ["da", "1943", "18"],
      ["da", "Danmarks_fodboldlandshold", "18"],
      ["da", "Colorado", "17"],
      ["da", "USA%27s_udenrigsministre", "17"],
      ["da", "2004", "15"],
      ["fi", "index.html", "393"],
      ["fi", "John_Kerry", "27"],
      ["fi", "Main_Page", "24"],
      ["fi", "Opus_caementicium", "22"],
      ["fi", "Facebook", "22"],
      ["fi", "Redi_(kauppakeskus)", "21"],
      ["fi", "J%C3%A4%C3%A4kiekon_SM-liigakausi_2005%E2%80%932006", "21"],
      ["fi", "Yhdysvaltain_senaatin_ulkoasiainvaliokunta", "21"],
      ["fi", "Massachusetts", "20"],
      ["fi", "Maksim_Bardat%C5%A1ou", "19"]
    ]

    assert expected_contents == file_contents
  end
end
