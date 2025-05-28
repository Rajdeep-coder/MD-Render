class MyDairy < ApplicationRecord
  self.table_name = :my_dairies
  has_secure_password
  validates :email, uniqueness: true, presence: true
  validates :I_agree_terms_and_conditions_and_privacy_policies, inclusion: { in: [true], message: "must be accepted!" }
  validates :phone_number, uniqueness: true, presence: true,
                           format: { with: /\A\d{10}\z/, message: 'must be a 10-digit number' }
  validates :password, presence: true,
                       length: { minimum: 8, message: 'must be minimum 8 characters' }, on: :create
  validates_format_of :email, multiline: true,
                              with: /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i
  has_many :customers
  has_many :devices
  has_many :notifications
  has_many :charts, dependent: :destroy
  has_many :rechargs, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :sell_milks, dependent: :destroy
  has_many :grades, dependent: :destroy
  accepts_nested_attributes_for :address, allow_destroy: true
  has_one_attached :image

  belongs_to :plan, optional: true

  after_create :create_chart, :create_recharg, :generate_referral_code

  def create_chart
    self.charts.create(name: "Cow")
    self.charts.create(name: "Buffalo")
    self.grades.create(name: "A")
  end

  def create_recharg
    plan = Plan.find_by_name("Free Trail")
    self.update_column("plan_id",plan.id)
    self.rechargs.create(plan_id: plan.id, activated: "true", expire_date: Date.current + plan.validity, amount: plan.amount)
  end

  def generate_referral_code
    rc = loop do
      code = SecureRandom.hex(4)
      formatted_code = "MD#{code}" 
      break formatted_code unless MyDairy.find_by('lower(referral_code) = ?',  formatted_code.downcase).present?
    end
    self.update_column("referral_code", rc)

    if self.referred_by_code?
      dairy = MyDairy.find_by('lower(referral_code) = ?',  self.referred_by_code.downcase)
      title = "🎉 Exciting News! 🎉"
      body = "Your friend, #{self.owner_name}, just signed up using your referral code! 🚀 We’re now waiting for their first recharge. Once that’s done, you’ll receive 10 days of free access to enjoy MilkDairy! 🎊"
      title_hindi = "🎉 शानदार खबर! 🎉"
      body_hindi = "आपके मित्र #{self.owner_name} ने आपके रेफरल कोड का उपयोग करके साइन अप किया है! 🚀 हम अब उनके पहले रिचार्ज का इंतजार कर रहे हैं। जैसे ही यह पूरा होगा, आपको MilkDairy का उपयोग करने के लिए 10 दिन मुफ्त मिलेंगे! 🎊"
      Notification.create!(
        title: title,
        body: body,
        title_hindi: title_hindi,
        body_hindi: body_hindi,
        notify_type: 'referral_dairy',
        my_dairy_id: dairy.id,
      )
    end
  end
end
