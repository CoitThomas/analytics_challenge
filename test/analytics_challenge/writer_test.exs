defmodule AnalyticsChallenge.WriterTest do
  use AnalyticsChallenge.RepoCase
  use ExUnit.Case

  alias AnalyticsChallenge.Persist
  alias AnalyticsChallenge.Writer

  @when_viewed ~N[2002-02-03 14:00:00]
  @batch_size 100

  def raw_pagecounts do
    [
      "en American_game_show_winnings_records 3 72777",
      "en American_gender_stereotypes 51 131614",
      "en American_ginseng 4 81516",
      "en American_gizzard_shad 17 13211",
      "en American_golden_plover 1 15523",
      "en American_gothic 2 35710",
      "en American_government 15 49598",
      "en American_handball 3 56517",
      "en American_heritage_magazine 22 67652",
      "en American_history_x 31 25914",
      "en American_holidays 21 98892",
      "en American_humor 3 74186",
      "en American_idiot 11 66915",
      "en American_immigration_to_Mexico 25 21453",
      "en American_imperialism 16 2665052",
      "es La_rebeli%C3%B3n_de_las_ratas 5 45376",
      "es La_reina_de_las_nieves 10 116505",
      "es La_reina_de_los_condenados 2 26198",
      "es La_reina_del_sur 9 93582",
      "es La_reina_del_sur_(telenovela) 7 155862",
      "es La_reine_Margot 33 11419",
      "es La_rendici%C3%B3n_de_Breda 44 15255",
      "es La_rendici%C3%B3n_de_Granada 55 11502",
      "es La_resistencia_(Ernesto_Sabato) 15 0",
      "es La_resistible_ascensi%C3%B3n_de_Arturo_Ui 21 11711",
      "es La_resurrecci%C3%B3n_de_Cristo_(Rafael) 2 71706",
      "es La_resurrecci%C3%B3n_de_L%C3%A1zaro 4 42595",
      "es La_revancha_(telenovela_de_1989) 31 12516",
      "es La_revancha_(telenovela_de_2000) 3 36933",
      "es La_revancha_del_pr%C3%ADncipe_charro 10 49170"
    ]
  end

  def path(file_descr, when_viewed) do
    dir_name = Application.get_env(:analytics_challenge, :writer)[:dir_name]
    file_ext = Application.get_env(:analytics_challenge, :writer)[:file_type]
    file_descr = file_descr

    Persist.build_file_path(dir_name, file_descr, when_viewed, file_ext)
  end

  setup do
    Persist.to_postgres(raw_pagecounts(), @when_viewed, @batch_size)
  end

  test "Writer succussfully queries and writes results to csv file for all language codes" do
    :ok = Writer.top_ten_for_all_at_hour(@when_viewed)

    # Check if the file is there
    path = path("top_ten_for_all_language_codes", @when_viewed)
    assert File.exists?(path)

    # Pull in everything from the file
    file_contents =
      path
      |> File.stream!()
      |> CSV.decode!()
      |> Enum.take(100)

    expected_contents = [
      ["en", "American_gender_stereotypes", "51"],
      ["en", "American_history_x", "31"],
      ["en", "American_immigration_to_Mexico", "25"],
      ["en", "American_heritage_magazine", "22"],
      ["en", "American_holidays", "21"],
      ["en", "American_gizzard_shad", "17"],
      ["en", "American_imperialism", "16"],
      ["en", "American_government", "15"],
      ["en", "American_idiot", "11"],
      ["en", "American_ginseng", "4"],
      ["es", "La_rendici%C3%B3n_de_Granada", "55"],
      ["es", "La_rendici%C3%B3n_de_Breda", "44"],
      ["es", "La_reine_Margot", "33"],
      ["es", "La_revancha_(telenovela_de_1989)", "31"],
      ["es", "La_resistible_ascensi%C3%B3n_de_Arturo_Ui", "21"],
      ["es", "La_resistencia_(Ernesto_Sabato)", "15"],
      ["es", "La_reina_de_las_nieves", "10"],
      ["es", "La_revancha_del_pr%C3%ADncipe_charro", "10"],
      ["es", "La_reina_del_sur", "9"],
      ["es", "La_reina_del_sur_(telenovela)", "7"]
    ]

    assert expected_contents == file_contents
    File.rm(path)
  end

  test "Writer succussfully queries and writes results to csv file for a subset of language codes" do
    :ok = Writer.top_ten_for_subset_at_hour(["es"], @when_viewed)

    # Check if the file is there
    path = path("top_ten_for_language_codes_subset", @when_viewed)
    File.exists?(path)

    # Pull in everything from the file
    file_contents =
      path
      |> File.stream!()
      |> CSV.decode!()
      |> Enum.take(100)

    expected_contents = [
      ["es", "La_rendici%C3%B3n_de_Granada", "55"],
      ["es", "La_rendici%C3%B3n_de_Breda", "44"],
      ["es", "La_reine_Margot", "33"],
      ["es", "La_revancha_(telenovela_de_1989)", "31"],
      ["es", "La_resistible_ascensi%C3%B3n_de_Arturo_Ui", "21"],
      ["es", "La_resistencia_(Ernesto_Sabato)", "15"],
      ["es", "La_reina_de_las_nieves", "10"],
      ["es", "La_revancha_del_pr%C3%ADncipe_charro", "10"],
      ["es", "La_reina_del_sur", "9"],
      ["es", "La_reina_del_sur_(telenovela)", "7"]
    ]

    assert expected_contents == file_contents
    File.rm(path)
  end

  test "Empty file for language codes with no pagecounts" do
    :ok = Writer.top_ten_for_subset_at_hour(["ko"], @when_viewed)

    # Check if the file is there
    path = path("top_ten_for_language_codes_subset", @when_viewed)
    File.exists?(path)

    # Pull in everything from the file
    file_contents =
      path
      |> File.stream!()
      |> CSV.decode!()
      |> Enum.take(100)

    assert [] == file_contents
    File.rm(path)
  end

  test "Empty file for language code that has pagecounts, but not from the hour provided" do
    when_viewed = ~N[2005-07-04 11:00:00]
    :ok = Writer.top_ten_for_subset_at_hour(["en"], when_viewed)

    # Check if the file is there
    path = path("top_ten_for_language_codes_subset", when_viewed)
    File.exists?(path)

    # Pull in everything from the file
    file_contents =
      path
      |> File.stream!()
      |> CSV.decode!()
      |> Enum.take(100)

    assert [] == file_contents
    File.rm(path)
  end
end
