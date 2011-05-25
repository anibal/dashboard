Then /^I should see current date formatted as "([^"]*)"$/ do |dont_care|
  formatted_date = Time.new.strftime "%A, %B %d, %Y"
  Then "I should see \"#{formatted_date}\" within \".date\"" 
end

Then /^I should see current hour formatted as "([^"]*)"$/ do |dont_care|
  Then "I should see /\\d{2}:\\d{2}:\\d{2}/ within \".time\"" 
end

