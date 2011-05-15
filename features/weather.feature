Feature: Weather display
  In order to know what to wear 
  I want weather information to be displayed in the dashboard
  
  Scenario:
    Given the day is "cloudy"
      And I visit the home page
     Then I should see "Showers in the Vicinity"
      And I should see "14°" degrees as "minimum" temperature
      And I should see "16°" degrees as "maximum" temperature
      And I should see the icon of a "clouded sun"

  Scenario:
    Given the day is "sunny"
      And I visit the home page
     Then I should see "Cider Weather"
      And I should see "13°" degrees as "minimum" temperature
      And I should see "16°" degrees as "maximum" temperature
      And I should see the icon of a "bright spotless sun"
