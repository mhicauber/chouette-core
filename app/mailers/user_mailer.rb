class UserMailer < ApplicationMailer
  def created user_id
    @user = User.find(user_id)
    mail to: Rails.configuration.subscriptions_notifications_recipients, subject: t('mailers.user_mailer.created.subject')
  end
end
