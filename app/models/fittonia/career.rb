class Fittonia::Career < ApplicationRecord
	enum status: [:application_received, :shortlisted, :written_exam_cleared, 
                :technical_interview_passed, :hr_interview_cleared, :on_hold, 
                :hiring_closed, :not_selected, :hiring_open]

	validates :first_name, :last_name, :email,:resume, presence: true
  validate :one_month_limit_email, on: :create
  validate :one_month_limit_phone_number, on: :create
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, format: {
    with: /\A\91\d{10}\z/,
    message: "Oops! The number you entered doesn't appear to be a valid phone number. A valid phone number should include the country code and be in the format: [CountryCode PhoneNumber]."
  }
	validates :skill, presence: true
	has_one_attached :resume

  before_save :convert_email_to_lowercase
  after_create :notify_administration
  after_save :send_status_email, if: :saved_change_to_status?
  
  def email=(value)
    super(value.downcase) if value.present?
  end

  def name
    first_name + ' ' + last_name
  end

	def json_data
    { 
    	first_name: first_name,
      last_name: last_name,
      email: email,
      phone_number: phone_number,
      resume: get_attachment(resume)

     }
  end

  def get_attachment(attach_name)
    return {} unless attach_name.attached?

    { id: attach_name.id,
      content_type: attach_name.content_type,
      url: ENV['BASE_URL'] + Rails.application.routes.url_helpers.rails_blob_url(attach_name, only_path: true) }
  end

  private

  def one_month_limit_email
    return unless email.present?

    last_contact = Fittonia::Career.where(email: email).order(created_at: :desc).first
    return unless last_contact && last_contact.created_at > 1.month.ago

    errors.add(:email, 'You can submit the career form only once per month by email.
                        For urgent inquiries, please contact us via phone.')
  end

  def one_month_limit_phone_number
    return unless phone_number.present?

    last_contact = Fittonia::Career.where(phone_number: phone_number).order(created_at: :desc).first
    return unless last_contact && last_contact.created_at > 1.month.ago

    errors.add(:phone_number, 'You can submit the career form only once per month by phone.
                              For urgent matters, we recommend using the email contact option.')
  end

  def convert_email_to_lowercase
    self.email = email.downcase if email.present?
  end

  def send_status_email
    Fittonia::CandidateMailer.send("#{status}_email", self).deliver_later
  end

  def notify_administration
    Fittonia::CandidateMailer.new_application_notification(self).deliver_later
    Fittonia::CandidateMailer.send("#{status}_email", self).deliver_later
  end
end
