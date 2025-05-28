class DepositHistory < ApplicationRecord 
  self.table_name = :deposit_histories
  validates :amount,  presence: true
  belongs_to :customer
  belongs_to :product, optional: true

  enum :deposit_type, [ :product, :cash ]

  after_create :store_deposit_payment_history
  before_create :check_product_amount
  after_create :create_notification_to_customer
  before_update :edit_notification_to_customer
  before_destroy :delete_notification_to_customer


  def store_deposit_payment_history
    PaymentHistory.create(status: "deposit",amount: self.amount&.round(2), customer_id: self.customer_id)
  end


  def check_product_amount
    if self.deposit_type == "product"
      amount = self.product.amount * self.quntity
      # if amount != self.amount
        self.amount = amount.round(2)
      # end
    end
  end

  def create_notification_to_customer
    if deposit_type == 'cash'
      title = "Cash Received!"
      title_hindi = "नकदी प्राप्त हुई!"
      body = "We're pleased to inform you that a cash transaction of Rs #{amount} has been completed successfully."
      body_hindi = "हमें आपको यह बताते हुए खुशी हो रही है कि #{amount} रुपये का नकद लेनदेन सफलतापूर्वक पूरा हो गया है।"
      type = 'create_cash'
    else
      title = "#{product&.name} (#{quntity}) Purchased!"
      title_hindi = "#{product&.name} (#{quntity}) खरीदा!"
      body = "You have successfully purchased #{product&.name} in #{quntity} quantity for Rs #{amount}."
      body_hindi = "आपने #{amount} रुपये में #{quntity} लीटर मात्रा में #{product&.name} सफलतापूर्वक खरीद लिया है"
      type = 'create_product'
    end
    create_notification(title, body, nil, type, title_hindi, body_hindi)
  end

  def edit_notification_to_customer 
    previous_data = DepositHistory.find_by(id: self.id)
    if deposit_type == 'cash'
      title = "Cash Received Updated"
      title_hindi = "नकद प्राप्ति परिवर्तन"
      body = "We're pleased to inform you that a cash transaction has been updated from Rs #{previous_data.amount} to Rs #{amount}."
      body_hindi = "हमें आपको यह बताते हुए खुशी हो रही है कि नकद लेनदेन को #{previous_data.amount} से रु.#{amount} में अपडेट कर दिया गया है।"
      type = 'update_product'
    else
      title = "#{product&.name} (#{quntity}) Purchased Updated"
      title_hindi = "#{product&.name} (#{quntity}) खरीदा गया अद्यतन किया गया"
      body = "Your purchase of #{previous_data.product&.name} in #{previous_data.quntity} quantity for Rs #{previous_data.amount} has been updated to #{product&.name} in #{quntity} quantity for Rs #{amount}."
      body_hindi = "आपकी #{previous_data.product&.name} की #{previous_data.quntity} मात्रा में #रुपये में की गई खरीदारी को #{amount} में #{quntity} मात्रा में #{product&.name} में अपडेट कर दिया गया है।"
      type = 'update_product'
    end
    create_notification(title, body, previous_data, type, title_hindi, body_hindi)
  end

  def delete_notification_to_customer
    if deposit_type == 'cash'
      title = "Cash Received Deleted"
      title_hindi = "प्राप्त नकद हटा दिया गया"
      body = "We regret to inform you that the entry for the cash transaction of Rs #{amount} has been deleted."
      body_hindi = "आपको यह सूचित करते हुए खेद हो रहा है कि रुपये #{amount} के नकद लेनदेन की प्रविष्टि हटा दी गई है।"
      type = 'delete_product'
    else
      title = "#{product&.name} (#{quntity}) Purchased Deleted"
      title_hindi = "#{product&.name} (#{quntity}) खरीदा गया हटाया गया"
      body = "We regret to inform you that the purchase of #{product&.name} in #{quntity} quantity for Rs #{amount} has been deleted."
      body_hindi = "हमें आपको यह बताते हुए खेद हो रहा है कि #{amount} रुपये में #{quntity} मात्रा में #{product&.name} की खरीदारी हटा दी गई है।"
      type = 'delete_product'
    end
    create_notification(title, body, nil, type, title_hindi, body_hindi)
  end

  def create_notification(title, body, previous_data, notify_type, title_hindi, body_hindi)
    Notification.create(
      title: title,
      body: body,
      title_hindi: title_hindi,
      body_hindi: body_hindi,
      notify_type: notify_type,
      customer_id: self.customer_id,
      my_dairy_id: self.customer.my_dairy_id,
      current_data: self,
      previous_data: previous_data
    )
  end
end
