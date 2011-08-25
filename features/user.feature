Feature: A user performs basic actions with his or her account
  In order to use the application
  As a user
  I want to log in, log out, edit and update my account

  Scenario: Log in
    Given I have an account with credentials zifro/pazzword
    When I go to the login page
		And I fill in "user_session[username]" with "zifro"
    And I fill in "user_session[password]" with "pazzword"
    And I press "Login"
    Then I should see "Successfully logged in"

	Scenario: Log out
  	Given I am logged in as zifro
    When I go to the home page
    And I follow "Logout"
    Then I should see "Login"

	Scenario: Logout link is not displayed when not logged in
		Given I go to the login page
		Then I should not see "Logout"

	Scenario: Logout link is displayed when logged in
		Given I am logged in as zifro
    When I go to the home page
		Then I should see "Logout"
		
	Scenario: Account link is not displayed when not logged in
		Given I go to the login page
		Then I should not see "Account"
		
	Scenario: Account link is displayed when logged in
		Given I am logged in as zifro
    When I go to the home page
		Then I should see "Account"
		
	Scenario: Browsing to the account page
		Given I am logged in as zifro
	  When I go to the home page
		And I follow "Account"
		Then I should be on the account page
		
	Scenario: Updating the user account
		Given I am logged in as zifro
		When I go to the account page
		And I fill in "user[username]" with "zeke"
		And I press "Update"
		Then I should be on the account page
		And I should see "Your account has been successfully updated"
		And I should see "Hi zeke!"
