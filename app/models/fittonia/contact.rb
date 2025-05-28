class Fittonia::Contact < ApplicationRecord
	after_create :send_welcome_email
  validates :first_name, :last_name, :email, :phone_number, presence: true
  validate :one_month_limit_email, if: :email_present?
  validate :one_month_limit_phone_number, if: :phone_number_present?
  validate :custom_email_validation

  before_save :convert_email_to_lowercase
  def email=(value)
    super(value.downcase) if value.present?
  end

  def email_present?
    email.present?
  end

  def phone_number_present?
    phone_number.present?
  end

  def send_welcome_email
    Fittonia::UserMailer.welcome_message(self).deliver_later
  end

  def fullname
    "#{first_name} #{last_name}"
  end

  private

  def one_month_limit_email
    return unless email.present?

    last_contact = Fittonia::Contact.where(email: email).order(created_at: :desc).first
    return unless last_contact && last_contact.created_at > 1.month.ago

    errors.add(:email, 'You can submit the contact form only once per month by email.
                        For urgent inquiries, please contact us via phone.')
  end

  def one_month_limit_phone_number
    return unless phone_number.present?

    last_contact = Fittonia::Contact.where(phone_number: phone_number).order(created_at: :desc).first
    return unless last_contact && last_contact.created_at > 1.month.ago

    errors.add(:phone_number, 'You can submit the contact form only once per month by phone.
                              For urgent matters, we recommend using the email contact option.')
  end

  def custom_email_validation
    return unless email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)

    errors.add(:email, 'is not a valid email address') unless email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def convert_email_to_lowercase
    self.email = email.downcase if email.present?
  end
end
