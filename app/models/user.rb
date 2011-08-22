class User < ActiveRecord::Base
  acts_as_authentic
  
  belongs_to :couple
  has_many :expenses
  
  validates_inclusion_of :gender, :in => ['M', 'F'], :allow_nil => true
  
end
