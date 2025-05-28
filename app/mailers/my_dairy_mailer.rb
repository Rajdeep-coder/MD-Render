class MyDairyMailer < ApplicationMailer
  def send_otp(user)
    @user = user
    mail(to: @user.email, subject: 'Otp for verification')
  end
end
