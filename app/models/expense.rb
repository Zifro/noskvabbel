class Expense < ActiveRecord::Base
  
  default_scope :order => 'spent_on DESC, id desc'
  
  belongs_to :user
  
  validates :user, :label, :spent_on, :presence => true
  validates :amount, :presence => true,
                     :numericality => { :greater_than_or_equal_to => 0.01 }
  
  attr_accessible :label, :amount, :spent_on
  
end
