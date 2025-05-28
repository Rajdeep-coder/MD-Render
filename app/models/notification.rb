class Notification < ApplicationRecord
  self.table_name = :notifications
  belongs_to :notifier, class_name: 'MyDairy', optional: true
  belongs_to :customer, optional: true
  belongs_to :my_dairy, optional: true
  after_create :send_push_notification

  def send_push_notification
    SendPushNotificationJob.perform_later(id)
  end
end
