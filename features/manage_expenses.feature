Feature: A user manages the expenses
  In order to review the expenses
  As a user
  I want to display the expenses recorded, create new ones, update and delete existing ones


  Scenario: Browsing to the expenses page
    Given I am logged in as zifro
		And user zifro is in couple
    When I go to the expenses page
    Then I should see "List of expenses"

	Scenario: Displaying expenses on the said page @wip
		Given I am logged in as zifro
		And user zifro is in couple
		And user zifro has recorded following expenses:
		| label      | amount | spent_on    |
		| Grocery    | 50.50  | 2011-08-19  |
		| Restaurant | 63.20  | 2011-08-18  |
		| Grocery    | 10.60  | 2011-08-17  |
		| DVD        | 14.90  | 2011-08-16  |
	  When I go to the expenses page
	  Then I should see the following expenses:
		| label      | amount | spent_on    |
		| Grocery    | 50.50  | 2011-08-19  |
		| Restaurant | 63.20  | 2011-08-18  |
		| Grocery    | 10.60  | 2011-08-17  |
		| DVD        | 14.90  | 2011-08-16  |