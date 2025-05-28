# app/jobs/send_push_notification_job.rb

class SendPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find(notification_id)
    if notification.customer&.devices.present? || (notification.customer.nil? && notification.my_dairy&.devices.present?)
      fcm_client = FCM.new([FCM_CONFIG[:api_token]], FCM_CONFIG[:credentials_path], FCM_CONFIG[:project_id])
      tokens = if notification.customer.present?
                notification.customer.devices.last(2).pluck(:token).uniq
              else
                notification.my_dairy.devices.last(4).pluck(:token).uniq
              end
      tokens.each do |token|
        message = {
          token: token,
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: {
            title: notification.title,
            body: notification.body,
            title_hindi: notification.title_hindi,
            body_hindi: notification.body_hindi,
          }
        }
        fcm_client.send_v1(message)
      end
    end
  rescue Exception => e
    Rails.logger.error("Failed to send push notification: #{e.message}")
  end
end
