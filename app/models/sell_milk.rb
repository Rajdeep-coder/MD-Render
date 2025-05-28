class SellMilk < ApplicationRecord
  self.table_name = :sell_milks
  validates :shift, :date, presence: true
  belongs_to :my_dairy
  validates :date, uniqueness: { scope: [:shift, :my_dairy], message: 'already has a bill for this shift and dairy' }

  enum shift: [:morning, :evening]

  before_save :set_values

  def set_values
    self.benifit = (self.amount - self.total_amount).round(2)
    self.weight_lose = (self.quntity - self.total_quntity).round(2)
  end
end
