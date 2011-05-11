require 'vcr_cucumber_helpers.rb' #TODO: Fix this require, already opened a ticket at https://github.com/myronmarston/vcr/issues/63
require 'vcr'

VCR.config do |c|
  c.stub_with :webmock
  c.cassette_library_dir     = 'features/cassettes'
  c.default_cassette_options = { :record => :new_episodes }
end

