class PaymentHistory < ApplicationRecord
  self.table_name = :payment_histories
  validates :amount,:status, presence: true 
  belongs_to :customer

  enum :status, [ :credit, :deposit ]

  after_create :calculate_payment

  def calculate_payment
    customer  = CustomerAccount.find_by_customer_id(self.customer_id)
    if customer.present?
      if self.status.eql?("credit")
        amount = ( customer.credit + self.amount ).round(2)
        customer.update(credit: amount, balance: (amount - customer.deposit).round(2))
      else
        amount = ( customer.deposit + self.amount ).round(2)
        customer.update(deposit: amount, balance:  (customer.credit - amount).round(2))
      end
    else
      if self.status.eql?("credit")
        CustomerAccount.create(credit: self.amount.round(2), deposit: 0, balance: self.amount.round(2), customer_id: self.customer_id)
      else
        CustomerAccount.create(credit: 0, deposit: self.amount.round(2), balance: -(self.amount.round(2)), customer_id: self.customer_id)
      end
    end
  end
end
