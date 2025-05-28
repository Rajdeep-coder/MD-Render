class Recharg < ApplicationRecord
  self.table_name = :rechargs

  TRANSLATION = {
    "1 Month"=> "1 महीना",
    "3 Months"=> "3 महीना",
    "6 Months"=> "6 महीना",
    "1 Year"=> "1 वर्ष",
    "5 Years"=> "5 वर्ष"
  }

  belongs_to :my_dairy
  belongs_to :plan
  
  enum activated: [:false, :true ]
  after_create :updated_activated

  private 

  def updated_activated
    my_dairy.update_column("plan_id", plan_id)
    unless my_dairy.plan.name == 'Free Trail'
      expire_date = my_dairy.rechargs.find_by(activated: true).expire_date
      my_dairy.rechargs.update_all(activated: "false")
      validity = plan.validity
      if expire_date > Date.current
        difference = expire_date - Date.current
        self.update_columns(activated: true, expire_date: Date.current + difference + validity)
      else
        self.update_columns(activated: true, expire_date: Date.current + validity)
      end
      referral_dairy_recharg if my_dairy.referred_by_code? && my_dairy.rechargs.count == 2

      title = "Recharge Successful! 🎉"
      body = "Congratulations, #{my_dairy.owner_name}! Your recharge for #{plan.name} has been successfully completed. Enjoy uninterrupted access to MilkDairy!"
      title_hindi = "रिचार्ज सफल हुआ! 🎉"
      body_hindi = "बधाई हो, #{my_dairy.owner_name}! आपका #{TRANSLATION[plan.name]} का रिचार्ज सफलतापूर्वक पूरा हो गया है।"
      Notification.create!(
        title: title,
        body: body,
        title_hindi: title_hindi,
        body_hindi: body_hindi,
        notify_type: 'recharg',
        my_dairy_id: my_dairy.id,
      )
    end
  end

  def referral_dairy_recharg
    dairy = MyDairy.find_by('lower(referral_code) = ?',  my_dairy.referred_by_code.downcase)
    referral_recharg = dairy.rechargs.find_by(plan_id: dairy.plan.id, activated: true)

    if referral_recharg.expire_date > Date.current
      difference = referral_recharg.expire_date - Date.current
      referral_recharg.update_columns(expire_date: Date.current + difference + 10)
    else
      referral_recharg.update_columns(expire_date: Date.current + 10)
    end

    title = "🎉 Your Reward Awaits! 🎉"
    body = "Great news! Your friend, #{my_dairy.owner_name}, has completed their first recharge! 🎊 Enjoy 10 days of free access to MilkDairy as a thank you for your referral! 😊"
    title_hindi = "🎉 आपका इनाम तैयार है! 🎉"
    body_hindi = "शानदार खबर! आपके मित्र #{my_dairy.owner_name} ने अपना पहला रिचार्ज पूरा कर लिया है! 🎊 आपके रेफरल के लिए धन्यवाद स्वरूप, MilkDairy का उपयोग करने के लिए 10 दिन मुफ्त का आनंद लें! 😊"
    Notification.create!(
      title: title,
      body: body,
      title_hindi: title_hindi,
      body_hindi: body_hindi,
      notify_type: 'referral_dairy_recharg',
      my_dairy_id: dairy.id,
    )
  end
end
