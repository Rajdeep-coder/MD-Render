class Chart < ApplicationRecord
  self.table_name = :charts
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :my_dairy_id
  belongs_to :my_dairy
  has_many :chart_rates, dependent: :destroy
end
