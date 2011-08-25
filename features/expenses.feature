Feature: A user manages the expenses
  In order to review the expenses
  As a user
  I want to display the expenses recorded, create new ones, update and delete existing ones

  Scenario: Browsing to the expenses page when not logged in
    Given I'm not logged in
    When I go to the expenses page
    Then I should be on the login page
		And I should see "Please login first"
		
	Scenario: Browsing to the expenses page when not in couple
    Given I am logged in as zifro
    When I go to the expenses page
    Then I should be on the login page
		And I should see "not in couple"

  Scenario: Browsing to the expenses page when logged in
    Given I am logged in as zifro
		And user zifro is in couple
    When I go to the expenses page
    Then I should see "List of expenses"
		And I should see "Record a new expense"

	Scenario: Displaying expenses on the said page
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
		| Grocery    | 50,50  | 2011-08-19  |
		| Restaurant | 63,20  | 2011-08-18  |
		| Grocery    | 10,60  | 2011-08-17  |
		| DVD        | 14,90  | 2011-08-16  |
	
	Scenario: Browsing to the new expense page
		Given I am logged in as zifro
		And user zifro is in couple
		When I go to the expenses page
		And I follow "Record a new expense"
		Then I should see "Provide the following information to record a new expense"
		And I should see "Label"
		And I should see "Amount"
		And I should see "Date"
		
	Scenario: Creating a new expense
		Given I am logged in as zifro
		And user zifro is in couple
		When I go to the new expense page
		And I fill in "expense[label]" with "Bought soft drinks for the party"
		And I fill in "expense[amount]" with "99.60"
		And I fill in "expense[spent_on]" with "2011-08-19"
    And I press "Record"
    Then I should see the following expense:
		| label                            | amount | spent_on    |
		| Bought soft drinks for the party | 99,60  | 2011-08-19  |
	
	Scenario: Display the embedded action links
		Given I am logged in as zifro
		And user zifro is in couple
		And user zifro has recorded following expenses:
		| label      | amount | spent_on    |
		| Grocery    | 50.50  | 2011-08-19  |
		When I go to the expenses page
		Then I should see "Edit"
		And I should see "Delete"
	
	Scenario: Browsing to the edit expense page
		Given I am logged in as zifro
		And user zifro is in couple
		And user zifro has recorded following expenses:
		| label      | amount | spent_on    |
		| Grocery    | 50.50  | 2011-08-19  |
		When I go to the expenses page
		And I follow "Edit"
#		Then I should be on the edit expense page
		And I should see "Please edit the following expense details at your will, then press Update"
	
	Scenario: Updating an expense
		Given I am logged in as zifro
		And user zifro is in couple
		And user zifro has recorded following expenses:
		| label      | amount | spent_on    |
		| Grocery    | 50.50  | 2011-08-19  |
		When I go to the expenses page
		And I follow "Edit"
		And I fill in "expense[label]" with "Aldi"
		And I fill in "expense[amount]" with "49.90"
		And I fill in "expense[spent_on]" with "2011-08-20"
		And I press "Update"
		Then I should be on the expenses page
		And I should see the following expense:
		| label   | amount | spent_on    |
		| Aldi    | 49,90  | 2011-08-20  |
		And I should see "Expense successfully updated"

	Scenario: Deleting an expense
		Given I am logged in as zifro
		And user zifro is in couple
		And user zifro has recorded following expenses:
		| label      | amount | spent_on    |
		| Grocery    | 50.50  | 2011-08-19  |
		When I go to the expenses page
		And I follow "Delete"
		Then I should see "Expense successfully deleted"
	