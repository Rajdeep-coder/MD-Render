class Product < ApplicationRecord
  self.table_name = :products
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :my_dairy_id
  validates :amount, presence: true
  belongs_to :my_dairy
  has_many :deposit_histories
  before_create :set_sid
  before_save :reset_low_stock_notification, if: -> { stock_quantity > MINIMUM_STOCK_LEVELS.last }

  MINIMUM_STOCK_LEVELS = [3, 5, 10, 15]

  def set_sid
    self.sid = my_dairy.products.count + 1
  end

  def in_stock?(quantity)
    stock_quantity >= quantity
  end

  def reduce_stock(quantity)
    return if self.stock_quantity.nil?

    self.stock_quantity -= quantity
    save!

    check_and_notify_low_stock if (stock_quantity > 0 || last_low_stock_threshold.nil?)
  end

  private

  def check_and_notify_low_stock
    current_level = MINIMUM_STOCK_LEVELS.find { |level| stock_quantity < level }

    if current_level && (last_low_stock_threshold.nil? || (last_low_stock_threshold > current_level))
      send_low_stock_notification(current_level)
      update!(last_low_stock_threshold: current_level)
    end
  end

  def send_low_stock_notification(threshold)
    title = "Low Stock Alert 📉"
    body = "Attention, #{my_dairy.owner_name}! The stock for #{name} is below #{threshold}. Please restock to ensure availability."
    title_hindi = "कम स्टॉक अलर्ट 📉"
    body_hindi = "ध्यान दें, #{my_dairy.owner_name}! #{name} का स्टॉक #{threshold} से कम है। कृपया उपलब्धता सुनिश्चित करने के लिए फिर से स्टॉक करें।"

    Notification.create(
      title: title,
      body: body,
      title_hindi: title_hindi,
      body_hindi: body_hindi,
      notify_type: 'low_stock',
      my_dairy_id: my_dairy.id
    )
  end

  def reset_low_stock_notification
    self.last_low_stock_threshold = nil
  end
end
