class Expense < ActiveRecord::Base
  
  belongs_to :user
  
  validates :user, :label, :spent_on, :presence => true
  validates :amount, :presence => true,
                     :numericality => { :greater_than_or_equal_to => 0.01 }
  
  
end
