# AnalyticsChallenge

## Description

This project acts as a pipeline for storing and analyzing a dataset from Wikipedia's publicly available server logs found here: http://dumps.wikimedia.org/other/pagecounts-raw

Upon storage of the dataset, the project can be used to find the 10 most popular Wikipedia pages, by language, for any arbitrary date and hour chosen.

***NOTE***: Although it is possible to fetch the pagecount data for an arbitrary date and hour, it is only possible to fetch a data set for an arbitrary date and hour within a fixed range determined by Wikipedia. That range is as follows:

    ~N[2007-12-09 18:00:00] - ~N[2016-08-05 12:00:00]

Or if you prefer: 6:00 PM December 9, 2007 - 12:00 PM August 5, 2016

## Getting Started

You will need to make sure that the following prerequisites are installed on your local machine:
- Elixir 1.11.4 (compiled with Erlang/OTP 23) or higher
    - [macOS](https://elixir-lang.org/install.html#macos)
    - [Windows](https://elixir-lang.org/install.html#windows)
    - [GNU/Linux](https://elixir-lang.org/install.html#gnulinux) 
- Docker/Docker Compose
    - On desktop systems like Docker Desktop for Mac and Windows, Docker Compose is included as part of those desktop installs. On Linux systems, you'll need to install Docker and Docker Compose separately.
        - [macOS](https://docs.docker.com/desktop/mac/install/)
        - [Windows](https://docs.docker.com/desktop/windows/install/)
        - GNU/Linux:
            - [Docker](https://docs.docker.com/engine/install/)
            - [Docker Compose](https://docs.docker.com/compose/install/) (alternatively, `sudo apt-get docker-compose`)

### Setup Instructions

Clone the repo.

Get your dependencies:

    $ mix deps.get

Build, create, start, and attach to the Docker container that houses a PostgreSQL database:

    $ docker-compose up -d  # you might need to use sudo here 

Create the storage for the AnalyticsChallenge.Repo and run the migrations for your database:

    $ mix ecto.create
    $ mix ecto.migrate

### Tests

For testing, run the following command:

    $ mix test

## Architecture

### Supervision Tree

AnalyticsChallenge is an OTP Elixir application with the following supervision tree:

![AnalyticsChallenge Supervision Tree](https://github.com/CoitThomas/analytics_challenge/blob/master/images/supervision_tree.png)

**AnalyticsChallenge.Loader**: GenServer child process which makes HTTP requests to Wikipedia for the raw pagecounts data, processes the data, and loads it into the database.

**AnalyticsChallenge.Repo**: Child process that runs, maintains, and interacts with the database. This happens by way of the Postgres Ecto adaptor and Postgrex.

**AnalyticsChallenge.Writer**: GenServer child process which queries the database and writes the data out to a CSV file. There are currently 2 queries that it can run.

### Database Schema

This is a pretty simple schema composed of one table, `pagecounts`, which has the following columns and data types:

![Pagecounts Table](https://github.com/CoitThomas/analytics_challenge/blob/master/images/pagecounts_table.png)

It's worth noting that a `when_viewed` column of type "timestamp w/out timezone" (NaiveDatetime in Elixir) has been included along with a unique index that covers the `language_code`, `page_name`, and `when_viewed` columns. The hope here was to be able to store more than just a single hour in our database for the same language and page. In this way, there can be added flexibility later to make more interesting queries which allow for aggregating data across specific periods of time (e.g. the whole month of January 2014 or the whole year of 2009) for a particular page.

## Usage

First, let's open an iex session which will get the application up and running:

    $ iex -S mix

Next, pick any date and hour that falls within the range listed at the top of the README and form it into a `NaiveDatetime`. When crafting your NaiveDatetime, keep in mind that 'hour' is the smallest level of granularity for this data set. Including anything other than zeros for the minutes and seconds of the NaiveDatetime will not yield any results:

    iex(1)> date_and_hour = ~N[2016-07-01 02:00:00]

With your chosen date and hour in hand, we can now tell the **Loader** to do its job:

    iex(2)> AnalyticsChallenge.Loader.load_pagecounts_for_hour(date_and_hour)

Now would be a good time to go use the restroom or grab some coffee. You *are* inserting millions of rows of data into your database table afterall. Come back in about 7-8 minutes.

...

All done? Do you see the `:ok` atom? Want to take a detour for a second and verify that our entries are actually there? You can do that by running the following command:

    iex(3)> AnalyticsChallenge.Query.row_count()

Assuming they all made it, let's move on to the **Writer** process. There are two options for queries and the subsequent files they produce:
1. `top_ten_for_all_at_hour/1` - This will fetch the top ten most popular Wikipedia pages for the desired hour for *all* languages in the database.
2. `top_ten_for_subset_at_hour/2` - This will fetch the top ten most popular Wikipedia pages for a subset of chosen languages. You'll need to know the corresponding ISO 639-1, ISO 639-2, or ISO 639-3 language codes first.

I'm curious about the top ten most popular Wikipedia pages in English and Korean so let's try out the subset query first. The codes for those languages are "en" and "ko":

    iex(4)> AnalyticsChallenge.Writer.top_ten_for_subset_at_hour(["en", "ko"], date_and_hour)

And now for the big one. Note, if this happens to timeout on you the first time you run it, try running the command again. It should work the 2nd time:

    iex(5)> AnalyticsChallenge.Writer.top_ten_for_all_at_hour(date_and_hour)

There should now be a newly created `analytics` folder in the root directory of the project with two CSV files inside containing your data. Well done!

---

### Wish List

These were some remaining things that I would have also liked to do with the project had I the time:
- Create a release for the app and have it run in its own container so that the only requirement would be Docker
- Create more queries - specifically some centered around aggregating pagecounts to find the top ten pages over various periods of time
- Find and implement a good Mocks library to use for the http requests
- DRY out some of the tests
- Figure out the Postgrex.Protocol pool termination/timeout issue
