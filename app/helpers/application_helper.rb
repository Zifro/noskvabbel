# frozen_string_literal: true

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

  # Returns the DaisyUI text color class corresponding to the gender of the user
  def gender_text_class(user)
    case user.gender
    when 'F'
      'text-secondary'
    when 'M'
      'text-info'
    else
      'text-base-content/60'
    end
  end

  # Returns the DaisyUI badge class corresponding to the gender of the user
  def gender_badge_class(user)
    case user.gender
    when 'F'
      'badge-secondary'
    when 'M'
      'badge-info'
    else
      'badge-ghost'
    end
  end
end
