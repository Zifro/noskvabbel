Feature: A user manages the expenses
  In order to review the expenses
  As a user
  I want to display the expenses recorded, create new ones, update and delete existing ones


  Scenario: Browsing to the expenses page
    Given I am logged in as zifro
		And user zifro is in couple
    When I go to the expenses page
    Then I should see "List of expenses"