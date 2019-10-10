# LabWhere
A tool for tracking uniquely barcoded labware

## Getting Started

1. Get the right Ruby version

Make sure you have `ruby-2.5.6` installed. e.g. `rvm install ruby-2.5.6`.

2. Create a new gemset and install bundler (if necessary)

```bash
rvm use ruby-2.5.6@rails526 --create
gem install bundler
```

3. Download the dependencies

`bundle`

4. Set up the local database

The local database uses `sqlite`.

```bash
bundle exec rails db:environment:set
bundle exec rails db:create
bundle exec rails db:migrate
```

## Running The Specs

`bundle exec rspec`

## Running The Server

`bundle exec rails s`

## Generating the API Documentation

`bundle exec rails docs:api`

The documentation is written in [API Blueprint](https://apiblueprint.org/) and converted to HTML using the [Apiary CLI client](https://github.com/apiaryio/apiary-client) gem.

The documentation will be available at `/api`.