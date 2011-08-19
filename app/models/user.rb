class User < ActiveRecord::Base
  acts_as_authentic
  
  belongs_to :couple
  has_many :expenses
  
end
