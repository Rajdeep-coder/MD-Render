class Customer < ApplicationRecord
  self.table_name = :customers
  has_secure_password
  belongs_to :my_dairy
  belongs_to :chart, optional: true
  belongs_to :grade, optional: true
  has_many :buy_milks, dependent: :destroy
  has_many :deposit_histories, dependent: :destroy
  has_many :payment_histories, dependent: :destroy
  has_one :customer_account, dependent: :destroy
  has_many :devices
  has_many :notifications

  enum rate_type: [:fat, :fat_clr, :fat_snf]


  validates_uniqueness_of :sid, scope: :my_dairy_id

  validates :name, presence: true
  validates :phone_number, uniqueness: true, presence: true,
                           format: { with: /\A\d{10}\z/, message: 'must be a 10-digit number' }
  has_one_attached :image

  before_save :set_decode_text
  before_create :set_sid
  after_create :set_last_assigned_sid

  def respose_date
    {
      id: id,
      name: name,
      phone_number: phone_number,
      address: address,
      my_dairy_id: my_dairy_id,
      decode_text: decode_text,
      sid: sid,
      rate_type: rate_type,
      grade_id: grade_id,
      chart_id: chart_id,
      customer_account: customer_account_response
    }
  end

  def set_decode_text
    return unless self.password

    self.decode_text = self.password  
  end

  def customer_account_response
    credit = buy_milks.sum(:amount).round(2)
    deposit = deposit_histories.sum(:amount).round(2)
    {
      id: customer_account&.id,
      credit: credit,
      deposit: deposit,
      balance: (credit - deposit).round(2),
      customer_id: id,
    }
  end

  def set_sid
    return if self.sid

    self.sid = my_dairy.last_assigned_sid + 1
  end

  def set_last_assigned_sid
    my_dairy.update(last_assigned_sid: self.sid)
  end
end
