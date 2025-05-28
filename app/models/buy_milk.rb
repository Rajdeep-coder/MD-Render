class BuyMilk < ApplicationRecord
  self.table_name = :buy_milks
  belongs_to :customer
  belongs_to :chart, optional: true
  belongs_to :grade, optional: true
  validates  :fat, :quntity, :amount, presence: true

  after_create :store_credit_payment_history
  before_save :calculate_amount
  after_create :create_notification_to_customer
  before_update :edit_notification_to_customer
  before_destroy :delete_notification_to_customer
  enum shift: [:morning, :evening]
  enum rate_type: [:fat, :fat_clr, :fat_snf]

  def store_credit_payment_history
    PaymentHistory.create(status: "credit",amount: amount&.round(2), customer_id: customer_id)
  end

  def calculate_amount
    if rate_type == "fat"
      amount = calculate_amount_based_on_fat
    elsif rate_type == "fat_clr"
      amount = calculate_amount_based_on_clr
    else
      amount = calculate_amount_based_on_snf
    end
    self.amount = amount.round(2)
  end

  def calculate_amount_based_on_fat
    fat_price = grade.rate.to_f
    fat.to_f * fat_price * quntity.to_f
  end

  def calculate_amount_based_on_clr
    par_liter_price = chart.chart_rates.find_by(clr: clr, fat: fat).rate.to_f
    quntity.to_f * par_liter_price
  end

  def calculate_amount_based_on_snf
    par_liter_price = chart.chart_rates.find_by(snf: snf, fat: fat).rate.to_f
    quntity.to_f * par_liter_price
  end

  def create_notification_to_customer
    return unless notify_permission

    title = "Milk Purchase Confirmed  - #{date_time_en}"
    title_hindi = "दूध खरीद की पुष्टि की गई - #{date_time_hi}"
    body = "Thank you for supplying milk with the following parameters: Fat - #{fat}, Quntity - #{quntity}, Per/Liter - #{little_rate}"
    body_hindi = "निम्नलिखित मापदंडों के साथ दूध की आपूर्ति करने के लिए धन्यवाद: फैट - #{fat}, मात्रा - #{quntity}, राशि #{amount}, प्रति लीटर - #{little_rate}"
    body, body_hindi = parameter_on_permission(body, body_hindi)
    create_notification(title, body, nil, "create_sold_milk", title_hindi, body_hindi)
  end

  def edit_notification_to_customer
    return unless notify_permission

    title = "Milk Purchase Updated - #{date_time_en}"
    title_hindi = "दूध खरीद अपडेट किया गया - #{date_time_hi}"
    body = "Important Notice: The parameters of the milk you supplied have been updated. New values - Fat - #{fat}, Quntity - #{quntity}, Per/Liter - #{little_rate}"
    body_hindi = "महत्वपूर्ण सूचना: आपके द्वारा आपूर्ति किए गए दूध के पैरामीटर अपडेट कर दिए गए हैं। नए मान - फैट - #{fat}, मात्रा - #{quntity}, प्रति लीटर - #{little_rate}"
    body, body_hindi = parameter_on_permission(body, body_hindi)
    previous_data = BuyMilk.find_by(id: self.id)
    create_notification(title, body, previous_data, "edit_sold_milk", title_hindi, body_hindi)
  end

  def delete_notification_to_customer
    return unless notify_permission

    title = "Milk Purchase Entry Removed - #{date_time_en}"
    title_hindi = "दूध खरीद प्रविष्टि हटा दी गई - #{date_time_hi}"
    body = "We regret to inform you that the entry for the milk you supplied has been removed. 🚫🥛"
    body_hindi = "हमें आपको यह बताते हुए खेद हो रहा है कि आपके द्वारा आपूर्ति किए गए दूध की प्रविष्टि हटा दी गई है। 🚫🥛"
    create_notification(title, body, nil, "delete_sold_milk", title_hindi, body_hindi)
  end

  def parameter_on_permission(body, body_hindi)
    if @customer_permissions['clr'] == 'true'
      body += ", CLR - #{clr}"
      body_hindi += ", सीएलआर - #{clr}"
    end
    if @customer_permissions['snf'] == 'true'
      body += ", SNF - #{snf}"
      body_hindi += ", एसएनएफ - #{snf}"
    end
    if @customer_permissions['amount'] == 'true'
      body += ", Amount #{amount}"
      body_hindi += ", राशि #{amount}"
    end
    body += ". 🔄🥛"
    body_hindi += "। 🔄🥛"
    [body, body_hindi]
  end

  def date_time_en
    I18n.with_locale(:en) do
      "#{date.strftime('%d')} #{I18n.t(date.strftime('%b'))} #{date.strftime('%Y')}, #{I18n.t(shift)}"
    end
  end

  def date_time_hi
    I18n.with_locale(:hi) do
      "#{date.strftime('%d')} #{I18n.t(date.strftime('%b'))} #{date.strftime('%Y')}, #{I18n.t(shift)}"
    end
  end

  def create_notification(title, body, previous_data, notify_type, title_hindi, body_hindi)
    Notification.create(
      title: title,
      body: body,
      title_hindi: title_hindi,
      body_hindi: body_hindi,
      notify_type: notify_type,
      customer_id: customer_id,
      my_dairy_id: customer.my_dairy_id,
      current_data: self,
      previous_data: previous_data
    )
  end

  def notify_permission
    @customer_permissions = customer.my_dairy.customer_permissions['notifications']
    @customer_permissions['parent'] == 'true'
  end
end
