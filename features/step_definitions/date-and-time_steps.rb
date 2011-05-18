Given /^the date is "([^"]*)"$/ do |date|
  # http://www.louismrose.me.uk/post/876230592/freezing-time-in-cucumber
  Timecop.travel Chronic.parse(date)
end
