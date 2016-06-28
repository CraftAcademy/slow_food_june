Feature: As a user
  To be able to place an order
  I need to be able to log in to the site

Background:
  Given the following users exist
    |username |password|
    |admin    |admin   |

Scenario: Access the login page
  Given I am on the home page
  And I click "Log In"
  Then I should be on the login page

Scenario: Login a user
  Given I am on the login page
  And I fill in "Username" with "admin"
  And I fill in "Password" with "admin"
  And I click "Submit"
  Then I should see "Successfully logged in admin"
  And I should be on the home page

Scenario: Reject login with wrong credentials - wrong password
  Given I am on the login page
  And I fill in "Username" with "admin"
  And I fill in "Password" with "wrong_password"
  And I click "Submit"
  Then I should see "The username and password combination"
  And I should be on the login page

Scenario: Reject login with wrong credentials - wrong username
  Given I am on the login page
  And I fill in "Username" with "wrong_username"
  And I fill in "Password" with "password"
  And I click "Submit"
  Then I should see "The username you entered does not exist."
  And I should be on the login page
