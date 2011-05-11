Given /^it is a sunny day$/ do
  use_vcr_cassette "weather" #TODO: Not sure if this should come here
end

Given /^I visit the "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see "([^"]*)" degrees as "([^"]*)" temperature$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end


