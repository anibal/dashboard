Given /^the day is "([^"]*)"$/ do |description|
  @cassete = "weather_#{description}"
end

When /^(?:|I )visit (.+)$/ do |page_name|
  VCR.use_cassette(@cassete) do 
    When "I go to #{page_name}"
  end
end

Then /^I should see "([^"]*)" degrees as "([^"]*)" temperature$/ do |temperature, type|
  # TODO: This should test for low and high in an explicit way, current
  # HTML structure doesn't really allow it, so it will wait a new layout
  # with ID's for weather, max and min
  Then "I should see \"#{temperature}\" within \".temp\""
end

Then /^I should see the icon of a "(.+)"$/ do |icon|
  icon_sources = { 'clouded sun' => 'http://l.yimg.com/a/i/us/we/52/28.gif',
                   'bright spotless sun' => 'http://l.yimg.com/a/i/us/we/52/32.gif'  }
  Then "I should see the image \"#{icon_sources[icon]}\""
end
