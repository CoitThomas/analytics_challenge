# AnalyticsChallenge

## Description

This project acts as a pipeline for storing and analyzing a small dataset from Wikipedia's publicly
available server logs found here: http://dumps.wikimedia.org/other/pagecounts-raw

Upon storage of the dataset, the project can be used to find the 10 most popular Wikipedia pages, by
lanuage, for any arbitrary date and hour chosen.

***NOTE***: Although it is possible to fetch the pagecount data for an arbitrary date and hour, it
is only possible to fetch a data set for an arbitrary date and hour within a fixed range determined
by Wikipedia. That range is as follows:

    ~N[2007-12-09 18:00:00] - ~N[2016-08-05 12:00:00]

Or if you prefer: 6:00 PM December 9, 2007 - 12:00 PM August 5, 2016

## Getting Started

You will need to make sure that the following prerequisites are installed on your local machine:
- Elixir 1.11.4 (compiled with Erlang/OTP 23) or higher
- Docker

### Setup Instructions

Clone the repo

Get your dependencies:

    $ mix deps.get

Build, create, start, and attach to the Docker container that houses a PostgreSQL database:

    $ docker-compose up -d

Create the storage for the AnalyticsChallenge.Repo and run the migrations for your database:

    $ mix ecto.create
    $ mix ecto.migrate

### Tests

For testing, run the following command:

    $ mix test

## Architecture

AnalyticsChallenge is an OTP Elixir application with the following supervision tree:

![AnalyticsChallenge Supervision Tree](https://github.com/CoitThomas/analytics_challenge/blob/master/images/supervision_tree.png)

**AnalyticsChallenge.Loader**: Makes HTTP requests to Wikipedia for the raw pagecounts data, processes the data, and loads it into the database.

**AnalyticsChallenge.Repo**: Runs, maintains, and interacts with the database.

**AnalyticsChallenge.Writer**: Queries the database and writes the data out to a CSV file.

### Usage

First, let's open an iex session which will get the application up and running:

    $ iex -S mix

Next, pick any date that falls within the range listed at the top of the README and form it into a `NaiveDatetime`:

    iex(1)> date_and_hour = ~N[2016-07-01 02:00:00]

With your chosen date and hour in hand, we can now tell the **Loader** to do its job:

    iex(2)> AnalyticsChallenge.Loader.load_pagecounts_for_hour(date_and_hour)

Now would be a good time to go use the restroom or grab some coffee. You *are* inserting millions of rows of data into your database table afterall. Come back in about 5 minutes.

...

All done? Do you see the `:ok` atom? Want to take a detour for a second and verify that our entries are actually there? You can do that by running the following command:

    iex(3)> AnalyticsChallenge.Query.row_count()

Assuming they all made it, let's move on to the **Writer** process. There are two options for queries and the subsequent files they produce:
1. `top_ten_for_all_at_hour/1` - this will fetch the top ten most popular Wikipedia pages for the desired hour for *all* languages in the database
2. `top_ten_for_subset_at_hour/2` - this will fetch the top ten most popular Wikipedia pages for a subset of chosen languages. You'll need to know the corresponding ISO 639-1, ISO 639-2, or ISO 639-3 language codes first.

Let's try out the first one first:

    iex(4)> AnalyticsChallenge.Writer.top_ten_for_all_at_hour(date_and_hour)

And now the second one. I'm curious about the top ten most popular Wikipedia pages in English and Korean. The codes for those are "en" and "ko":

    iex(5)> AnalyticsChallenge.Writer.top_ten_for_subset_at_hour(["en", "ko"], date_and_hour)

There should now be a newly created `analytics` folder in the root directory of the project with two
CSV files inside containing your data. Well done!

---

### Wish List

These were some remaining things that I would have also liked to do with the project had I the time:
- Create a release for the app and have it run in its own elixir container so that the only requirement would be Docker
- Create more queries - specifically some centered around aggregating pagecounts to find the top ten pages over various periods of time (e.g. the whole month of January 2014, the whole year of 2009)
- Find and implement a good Mocks library to use for the http requests
- DRY out some of my tests


