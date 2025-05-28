class Plan < ApplicationRecord
  self.table_name = :plans

  has_many :rechargs
  has_one :my_dairy
end
