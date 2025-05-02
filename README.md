# FaaNotams

A Ruby gem for interacting with the FAA's Notice to Airmen (NOTAM) API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faa_notams'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install faa_notams
```

## Usage

First, obtain your API credentials from the [FAA External API Portal](https://external-api.faa.gov/).

### Basic Usage

```ruby
require 'faa_notams'

# Initialize with client credentials
client = FaaNotams.new(
  'your_client_id',
  'your_client_secret'
)

# Or use environment variables
# export FAA_NOTAM_CLIENT_ID=your_client_id
# export FAA_NOTAM_CLIENT_SECRET=your_client_secret
client = FaaNotams.new

# Search for NOTAMs
results = client.search(
  icao_location: 'KIAD',
  page_size: 50,
  page_num: 1
)

# Search by airport
results = client.search_by_airport('KIAD')
# or domestic code
results = client.search_by_airport('IAD')

# Search by geographic location
results = client.search_by_location(38.9445, -77.4558, 50)

# Search by feature type
results = client.search_by_feature('RWY')
```

### Available Search Parameters

The `search` method accepts the following parameters:

- `:response_format` - Format of the response ('aixm', 'geoJson', or 'aidap')
- `:icao_location` - ICAO location code (e.g., 'KIAD' for Dulles)
- `:domestic_location` - Domestic location code (e.g., 'IAD' for Dulles)
- `:notam_type` - The NOTAM type ('N' for New, 'R' for Replaced, or 'C' for Canceled)
- `:classification` - NOTAM classification ('INTL', 'MIL', 'DOM', 'LMIL', or 'FDC')
- `:notam_number` - The NOTAM number (e.g., 'CK0000/01')
- `:effective_start_date` - The effective start date (ISO 8601 format)
- `:effective_end_date` - The effective end date (ISO 8601 format)
- `:feature_type` - Feature type (e.g., 'RWY', 'TWY', 'AIRSPACE', etc.)
- `:location_longitude` - Location longitude (e.g., -151.24)
- `:location_latitude` - Location latitude (e.g., 60.57)
- `:location_radius` - Location radius in nautical miles (max: 100nm)
- `:last_updated_date` - Last updated date (ISO 8601 format)
- `:sort_by` - Field to sort by (e.g., 'icaoLocation', 'effectiveStartDate')
- `:sort_order` - Sort order ('Asc' or 'Desc')
- `:page_size` - Number of results per page (max: 1000, default: 50)
- `:page_num` - Page number (default: 1)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/faa_notams. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/yourusername/faa_notams/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FaaNotams project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yourusername/faa_notams/blob/main/CODE_OF_CONDUCT.md).
