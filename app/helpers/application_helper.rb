module ApplicationHelper

  # Returns the other lover in couple with the user passed as argument
  def other_mate_in_couple_with(user)
    couple = user.couple
    (couple.users - [user]).first
  end

end
