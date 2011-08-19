class Couple < ActiveRecord::Base
  
  has_many :users
  has_many :expenses, :through => :users
  
  validate :there_are_two_users
  
  
  protected
  
  def there_are_two_users
    errors.add(:users, "there must be two users (lovers) in a couple") unless users.length == 2
  end
  
end
