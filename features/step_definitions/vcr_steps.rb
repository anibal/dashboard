Given /^the day is "([^"]*)"$/ do |description|
  require 'vcr'
  VCR.config do |c|
    c.stub_with :webmock
    c.cassette_library_dir     = 'features/cassettes'
    c.default_cassette_options = { :record => :new_episodes }
    c.ignore_localhost = true
  end
  @cassete = "weather_#{description}"
end

When /^(?:|I )visit (.+)$/ do |page_name|
  VCR.use_cassette(@cassete) do 
    When "I go to #{page_name}"
  end
end

