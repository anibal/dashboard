Then /^I should see "([^"]*)" in the embedded Google Calendar$/ do |calendar_entry|
  #page.driver.browser.switch_to.frame ''
  #page.should have_content calendar_entry
  within_frame '' do 
    Then "I should see \"#{calendar_entry}\""
  end
end

