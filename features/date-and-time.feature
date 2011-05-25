Feature: Date and time display
  In order to be sure that "everything doesn't happen at once" - A. Einstein
  I want date and time information to be displayed in the dashboard
  
  @javascript
  Scenario: today
    Given I go to the home page
     Then I should see current date formatted as "Week day, Month Day, Year"
      And I should see current hour formatted as "hh:mm:ss"

