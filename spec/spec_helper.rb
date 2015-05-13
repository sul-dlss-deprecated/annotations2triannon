require 'coveralls'
Coveralls.wear!

require 'annotations2triannon'
require 'rspec'
RSpec.configure do |config|
end

require 'vcr'
cassette_ttl = 28 * 24 * 60 * 60  # 28 days, in seconds
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = {
    :record => :new_episodes,
    :re_record_interval => cassette_ttl
  }
  c.configure_rspec_metadata!
end
