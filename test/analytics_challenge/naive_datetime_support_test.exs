defmodule AnalyticsChallenge.NaiveDatetimeSupportTest do
  use ExUnit.Case

  alias AnalyticsChallenge.NaiveDatetimeSupport

  test "correct parsing and conversion of NaiveDatetime" do
    naive_datetime = ~N[2012-07-15 22:00:00]
    expected_tuple = {"2012", "07", "15", "22"}

    assert expected_tuple == NaiveDatetimeSupport.parse_to_strings(naive_datetime)
  end

  test "month, day, hour are single digits in need of padding" do
    naive_datetime = ~N[2012-01-05 02:00:00]
    expected_tuple = {"2012", "01", "05", "02"}

    assert expected_tuple == NaiveDatetimeSupport.parse_to_strings(naive_datetime)
  end

  test "month, day, hour are double digits not in need of padding" do
    naive_datetime = ~N[2012-11-25 12:00:00]
    expected_tuple = {"2012", "11", "25", "12"}

    assert expected_tuple == NaiveDatetimeSupport.parse_to_strings(naive_datetime)
  end
end
