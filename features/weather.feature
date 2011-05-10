Feature: Weather display
  In order to know what to wear 
  I want weather information to be displayed in the dashboard
  
  Scenario:
    Given it is a sunny day
      And I visit the "/"
     Then I should see "the sun shinning"
      And I should see "30" degrees as "minimum" temperature
      And I should see "40" degrees as "maximum" temperature
      And I should see "clear skies"
