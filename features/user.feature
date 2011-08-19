Feature: A user performs basic actions with his or her account
  In order to use the application
  As a user
  I want to log in and log out


  Scenario: Log in
    Given I have an account with credentials zifro/pazzword
    When I go to the home page
			And I fill in "user_session[username]" with "zifro"
			And I fill in "user_session[password]" with "pazzword"
			And I press "Go !"
    Then I should see "Welcome zifro :)"


	Scenario: Log out
	  Given I am logged in as zifro
	  When I go to the home page
			And I follow "Logout"
	  Then I should see "Sign up ?"
