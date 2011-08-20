Feature: A user can be in couple with another user
  In order to use the application
  As a user
  I need to be in couple

	Scenario: Displaying the username and the other mate in his or her couple
	  Given I am logged in as zifro
		And user zifro is in couple with gincy
	  When I go to the login page
	  Then I should see "Hi zifro! You're in couple with gincy."