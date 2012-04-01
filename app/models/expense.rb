class Expense < ActiveRecord::Base
  
  default_scope :order => 'spent_on DESC, id desc'
  
  belongs_to :user
  belongs_to :created_by, :class_name => 'User', :foreign_key => :created_by_id
  
  validates :user, :created_by, :label, :spent_on, :presence => true
  validates :amount, :presence => true,
                     :numericality => { :greater_than_or_equal_to => 0.01 }

  validate :the_expense_must_not_have_been_recorded_yet

  attr_accessible :label, :amount, :spent_on, :user, :user_id
  
  
  # Returns the spent_on attribute or its default value
  def spent_on
    self.attributes['spent_on'] ||= Date.today
  end
  

  private
  
  def the_expense_must_not_have_been_recorded_yet
    # verifies the same expense has not been recorded yet
    if new_record? && self.class.where(label: label, amount: amount, spent_on: spent_on).first
      errors.add(:base, 'This expense has already been recorded')
    end
  end

end
