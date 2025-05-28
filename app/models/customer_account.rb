class CustomerAccount < ApplicationRecord
  self.table_name = :customer_accounts
  validates :credit, :deposit, presence: true
end
