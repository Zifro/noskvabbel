module ApplicationHelper

  # Returns the other lover in couple with the user passed as argument
  def other_mate_in_couple_with(user)
    couple = user.couple
    (couple.users - [user]).first
  end
  
  # Returns an appropriate great message for the user passed as argument
  def greet_message_for(user)
    if user.couple
      "Hi #{user.username}! You're in couple with #{other_mate_in_couple_with(user).username}."
    else
      "Hi #{user.username}! Not in couple yet? Don't worry."
    end
  end

end
