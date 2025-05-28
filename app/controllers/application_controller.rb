class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authenticate_request
  before_action :set_env_base_url, :set_locale
  attr_accessor :current_user

  include JsonWebToken
  include Pagy::Backend

  private

  def set_env_base_url
    return if ENV['BASE_URL'].present?

    ENV['BASE_URL'] = request.base_url
  end

  def authenticate_request
    return if params[:controller].start_with?('admin/') || params[:controller].start_with?('active_admin/')
    begin
      token = request.headers['token']
      decoded = jwt_decode(token)
      @current_user = MyDairy.find_by_id(decoded[:my_dairy_id]) || Customer.find_by_id(decoded[:customer_id] )
      raise ActiveRecord::RecordNotFound unless @current_user.present?
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: 'User not found' }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: 'Invalid token' }, status: :unauthorized
    end
  end

  def format_activerecord_errors(errors)
    formatted_errors = {}

    errors.each do |error|
      attribute = error.attribute
      message = error.message

      formatted_errors[attribute] ||= []
      formatted_errors[attribute] << "#{attribute.to_s.titleize} #{message}"
    end

    formatted_errors.transform_values { |messages| messages.join(', ') }
  end

  def pagination(obj)
    pagy(obj, items: params[:items] || 20, page: params[:page] || 1)  if obj.present?
  end

  def set_locale
    I18n.locale = params[:locale].present? ? params[:locale] : I18n.default_locale
  end
end
