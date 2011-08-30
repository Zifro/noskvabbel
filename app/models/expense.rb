class Expense < ActiveRecord::Base
  
  default_scope :order => 'spent_on DESC, id desc'
  
  belongs_to :user
  belongs_to :created_by, :class_name => 'User', :foreign_key => :created_by_id
  
  validates :user, :created_by, :label, :spent_on, :presence => true
  validates :amount, :presence => true,
                     :numericality => { :greater_than_or_equal_to => 0.01 }
  
  attr_accessible :label, :amount, :spent_on, :user, :user_id
  
end
