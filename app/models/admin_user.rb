class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable
  def self.ransackable_attributes(auth_object = nil)
    %w[email created_at] # Add other attributes you want to make searchable
  end
end
