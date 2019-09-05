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
bundle exec rails db:setup
```

## Running The Specs

`bundle exec rspec`

## Running The Server

`bundle exec rails s`
