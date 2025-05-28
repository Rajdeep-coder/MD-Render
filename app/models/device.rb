class Device < ApplicationRecord
  self.table_name = :devices
  belongs_to :my_dairy, optional: true
  belongs_to :customer, optional: true
end
