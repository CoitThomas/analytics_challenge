# AnalyticsChallenge

---

## Description

This project acts as a pipeline for storing and analyzing a small dataset from Wikipedia's publicly
available server logs found here: http://dumps.wikimedia.org/other/pagecounts-raw
Upon storage of the dataset, the project can be used to find the 10 most popular Wikipedia pages, by
lanuage, for any arbitrary date and hour chosen.

***NOTE***: Although it is possible to fetch the pagecount data for an arbitrary date and hour, it
is only possible to fetch a data set for an arbitrary date and hour within a fixed range determined
by Wikipedia. That range is as follows:

    ~N[2007-12-09 18:00:00] - ~N[2016-08-05 12:00:00]

In English: 6:00 PM December 9, 2007 - 12:00 PM August 5, 2016

---

## Getting Started

You will need to make sure that the following prerequisites are installed on your local machine:
- Elixir 1.11.4 (compiled with Erlang/OTP 23) or higher
- Docker

### Setup Instructions

1. Clone this repo
2. Get your dependencies:
    mix deps.get
3. Build, create, start, and attach to the Docker container that houses a PostgreSQL database:
    docker-compose up -d
4. Create the storage for the AnalyticsChallenge.Repo and run the migrations for your database:
    mix ecto.create
    mix ecto.migrate

### Tests

For testing, run the following command:
    mix test

---

## Architecture

AnalyticsChallenge is an OTP Elixir application with the following supervision tree:

![AnalyticsChallenge Supervision Tree](https://github.com/CoitThomas/analytics_challenge/blob/master/images/supervision_tree.png)

### Usage

First, let's open an iex session which will get the application up and running:
    iex -S mix


---

### Wish List


