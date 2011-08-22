module ApplicationHelper

  # Returns the other lover in couple with the user passed as argument
  def other_mate_in_couple_with(user)
    couple = user.couple
    (couple.users - [user]).first
  end


  # Returns the CSS class corresponding to the gender of the user
  def gender(user)
    case user.gender
    when 'F'
      'female'
    when 'M'
      'male'
    else
      'gender'
    end
  end

end
