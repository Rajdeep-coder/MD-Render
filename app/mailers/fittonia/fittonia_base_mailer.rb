# app/mailers/fittonia/fittonia_base_mailer.rb
module Fittonia
  class FittoniaBaseMailer < ActionMailer::Base
    default from: ENV['FITTONIA_SMTP_USERNAME']
    layout "mailer"

    self.delivery_method = :smtp
    self.smtp_settings = {
      address: ENV['SMTP_ADDRESS'],
      port: ENV['SMTP_PORT'],
      domain: ENV['SMTP_DOMAIN'],
      user_name: ENV['FITTONIA_SMTP_USERNAME'],
      password: ENV['FITTONIA_SMTP_PASSWORD'],
      authentication: ENV['SMTP_AUTHENTICATION'],
      enable_starttls_auto: true
    }
  end
end
