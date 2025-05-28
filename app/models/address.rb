class Address < ApplicationRecord
  self.table_name = :addresses
  belongs_to :addressable, polymorphic: true
end
