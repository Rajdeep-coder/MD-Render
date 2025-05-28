# app/mailers/fittonia/user_mailer.rb
module Fittonia
  class UserMailer < Fittonia::FittoniaBaseMailer
    def welcome_message(contact)
      @contact = contact
      mail(to: @contact.email, subject: 'Contact Form Submission Received')
    end
  end
end
