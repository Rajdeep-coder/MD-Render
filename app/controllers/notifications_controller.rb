class NotificationsController < ApplicationController
  before_action :authenticate_request
  before_action :find_notification, only: %i[show update]

  def index
    locale = params[:locale] || "en"
    notifications = if @current_user.instance_of?(MyDairy)
                      @current_user.notifications.where(customer_id: nil)&.order(created_at: :desc)
                    else
                      @current_user.notifications&.order(created_at: :desc)
                    end
    pagy, data = pagination(notifications)
    render json: { data: data&.map{ |nofication| NotificationSerializer.new(nofication, locale: locale) }, pagination: pagy, locale: locale }, status: :ok
  end

  def create_device
    device = @current_user.devices.find_or_initialize_by(token: params[:token])
    if device.new_record?
      device.save!
    else
      device.touch
    end
    devices_to_keep = @current_user.devices.order(created_at: :desc).limit(4)
    devices_to_delete = @current_user.devices.where.not(id: devices_to_keep.pluck(:id))
    devices_to_delete.destroy_all
    render json: device, status: :ok
  end

  def logout
    device = Device.find_by(token: params[:token])
    device.destroy if device
    render json: device, status: :ok
  end

  def show
    locale = params[:locale] || "en" 
    render json: { data: NotificationSerializer.new(@nofications,locale), status: :ok }
  end

  def update
    @nofications.update(is_read: true)
    render json: { data: NotificationSerializer.new(@nofications), message: 'Notifacation mark as read' }, status: :ok
  end

  private

  def find_notification
    @nofications = @current_user.notifications.find_by(id: params[:id])
    not_found unless @nofications.present?
  end
end
