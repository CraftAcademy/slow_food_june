Feature: As a user
  To be able to finalize my order
  I need to be able to log in to the site

Background:
  Given the following users exist
    |username|password|
    |admin   |admin   |

Scenario: Access the login page
  Given I am on the home page
  And I click "Log In"
  Then I should be on the login page
  # And I am not logged in

Scenario: Log in a user
  Given I am on the login page
  And I fill in "username" with "admin"
  And I fill in "password" with "admin"
  And I click on "Log In"
  Then I should see "Successfully logged in admin"
  And I should be on the home page
