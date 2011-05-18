Feature: Date and time display
  In order to be sure that "everything doesn't happen at once" - A. Einstein
  I want date and time information to be displayed in the dashboard
  
  @javascript
  Scenario: today
    Given I visit the home page
     Then I should see "Sunday, May 15, 2011"
      And I should see "08:42:15"

