class Grade < ApplicationRecord
	belongs_to :my_dairy
	has_many :customers
end
